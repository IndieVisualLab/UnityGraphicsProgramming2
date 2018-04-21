using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Assertions;

namespace CurlNoise
{
    public class Fire : MonoBehaviour
    {
        #pragma warning disable 0414
        struct FireParams
        {
            Vector3 emitPos;
            Vector3 position;
            Vector4 velocity; //xyz = velocity, w = velocity coef;
            Vector3 life;     // x = time elapsed, y = life time, z = isActive 1 is active, -1 is disactive.
            Vector3 size;     // x = current size, y = start size, z = target size.
            Vector4 color;
            Vector4 startColor;
            Vector4 endColor;

            public FireParams(Vector3 emitPos, float life, float startSize, float endSize, Color startColor, Color endColor)
            {
                this.emitPos = emitPos;
                this.position = Vector3.zero;
                this.velocity = Vector3.zero;
                this.life = new Vector3(0, life, -1);
                this.size = new Vector3(0, startSize, endSize);
                this.color = Color.white;
                this.startColor = startColor;
                this.endColor = endColor;
            }
        }

        public struct GPUThreads
        {
            public int x;
            public int y;
            public int z;

            public GPUThreads(uint x, uint y, uint z)
            {
                this.x = (int)x;
                this.y = (int)y;
                this.z = (int)z;
            }
        }

        public static class DirectCompute5_0
        {
            //Use DirectCompute 5.0 on DirectX11 hardware.
            public const int MAX_THREAD = 1024;
            public const int MAX_X = 1024;
            public const int MAX_Y = 1024;
            public const int MAX_Z = 64;
            public const int MAX_DISPATCH = 65535;
            public const int MAX_PROCESS = MAX_DISPATCH * MAX_THREAD;
        }

        [Serializable]
        public struct FireColors
        {
            public Color startColor;
            public Color endColor;
        }

        [Serializable]
        public struct FireSizes
        {
            [Range(0f, 10f)]
            public float startSize;
            [Range(0f, 10f)]
            public float endSize;
        }

        [Serializable]
        public struct FireLifes
        {
            [Range(0f, 60f)]
            public float minLife;
            [Range(0f, 60f)]
            public float maxLife;
        }

        #region Variables

        private enum ComputeKernels
        {
            Emit,
            Iterator
        }

        private Dictionary<ComputeKernels, int> kernelMap = new Dictionary<ComputeKernels, int>();
        private GPUThreads gpuThreads;

        [SerializeField] int instanceCount = 100000;
        [SerializeField] List<FireColors> fireColors = new List<FireColors>();
        [SerializeField] List<FireSizes> fireSizes = new List<FireSizes>();
        [SerializeField] List<FireLifes> fireLifes = new List<FireLifes>();
        [SerializeField] Vector3 additionalVector;
        [SerializeField] float emitterSize = 10f;
        [SerializeField] float convergence = 4f;
        [SerializeField] float convergenceFrequency = 3f;
        [SerializeField] float convergenceFrequencyDistance = 4f;
        [SerializeField] float viscosity = 5f;
        [SerializeField] Material instanceMaterial;
        [SerializeField] ComputeShader computeShader;

        private ComputeShader computeShaderInstance;
        private int cachedInstanceCount = -1;
        private ComputeBuffer fireBuffer;
        private float timer = 0f;

        private int fireBufferPropId;
        private int timesPropId;
        private int convergencePropId;
        private int viscosityPropId;
        private int additionalVectorPropId;
        private int modelMatrixPropId;

        #endregion

        void Initialize()
        {
            computeShaderInstance = computeShader;
            uint threadX, threadY, threadZ;
            kernelMap = System.Enum.GetValues(typeof(ComputeKernels))
                .Cast<ComputeKernels>()
                .ToDictionary(t => t, t => computeShaderInstance.FindKernel(t.ToString()));
            computeShaderInstance.GetKernelThreadGroupSizes(kernelMap[ComputeKernels.Emit], out threadX, out threadY, out threadZ);
            gpuThreads = new GPUThreads(threadX, threadY, threadZ);

            fireBufferPropId = Shader.PropertyToID("buf");
            timesPropId = Shader.PropertyToID("times");
            convergencePropId = Shader.PropertyToID("convergence");
            viscosityPropId = Shader.PropertyToID("viscosity");
            additionalVectorPropId = Shader.PropertyToID("additionalVector");
            modelMatrixPropId = Shader.PropertyToID("modelMatrix");

            InitialCheck();
            UpdateBuffers();
        }

        void InitialCheck()
        {
            Assert.IsTrue(SystemInfo.graphicsShaderLevel >= 50, "Under the DirectCompute5.0 (DX11 GPU) doesn't work");
            Assert.IsTrue(gpuThreads.x * gpuThreads.y * gpuThreads.z <= DirectCompute5_0.MAX_PROCESS, "Resolution is too heigh");
            Assert.IsTrue(gpuThreads.x <= DirectCompute5_0.MAX_X, "THREAD_X is too large");
            Assert.IsTrue(gpuThreads.y <= DirectCompute5_0.MAX_Y, "THREAD_Y is too large");
            Assert.IsTrue(gpuThreads.z <= DirectCompute5_0.MAX_Z, "THREAD_Z is too large");
            Assert.IsTrue(instanceCount <= DirectCompute5_0.MAX_PROCESS, "particleNumber is too large");
        }

        void Start()
        {
            Initialize();
        }

        void Update()
        {
            if (cachedInstanceCount != instanceCount)
                UpdateBuffers();

            computeShaderInstance.SetVector(timesPropId, new Vector2(Time.deltaTime, timer));
            computeShaderInstance.SetFloat(convergencePropId, convergence + Mathf.PerlinNoise(timer * convergenceFrequency, Mathf.PingPong(timer * convergenceFrequency, 1.0f)) * convergenceFrequencyDistance);
            computeShaderInstance.SetFloat(viscosityPropId, viscosity);
            computeShaderInstance.SetVector(additionalVectorPropId, additionalVector);

            computeShaderInstance.SetBuffer(kernelMap[ComputeKernels.Emit], fireBufferPropId, fireBuffer);
            computeShaderInstance.Dispatch(kernelMap[ComputeKernels.Emit], Mathf.CeilToInt((float)instanceCount / (float)gpuThreads.x), gpuThreads.y, gpuThreads.z);

            computeShaderInstance.SetBuffer(kernelMap[ComputeKernels.Iterator], fireBufferPropId, fireBuffer);
            computeShaderInstance.Dispatch(kernelMap[ComputeKernels.Iterator], Mathf.CeilToInt((float)instanceCount / (float)gpuThreads.x), gpuThreads.y, gpuThreads.z);

            timer += Time.deltaTime;
        }

        private void OnRenderObject()
        {
            Matrix4x4 modelMatrix = transform.localToWorldMatrix;
            instanceMaterial.SetPass(0);
            instanceMaterial.SetBuffer(fireBufferPropId, fireBuffer);
            instanceMaterial.SetMatrix(modelMatrixPropId, modelMatrix);
            Graphics.DrawProcedural(MeshTopology.Points, instanceCount);
        }

        void UpdateBuffers()
        {
            if (fireBuffer != null)
                fireBuffer.Release();

            fireBuffer = new ComputeBuffer(instanceCount, Marshal.SizeOf(typeof(FireParams)));
            FireParams[] fireParams = new FireParams[fireBuffer.count];
            for (int i = 0; i < instanceCount; i++)
            {
                var colors = fireColors[UnityEngine.Random.Range(0, fireColors.Count)];
                var sizes = fireSizes[UnityEngine.Random.Range(0, fireSizes.Count)];
                var life = fireLifes[UnityEngine.Random.Range(0, fireLifes.Count)];
                fireParams[i] = new FireParams(UnityEngine.Random.insideUnitSphere * emitterSize, UnityEngine.Random.Range(life.minLife, life.maxLife), sizes.startSize, sizes.endSize, colors.startColor, colors.endColor);
            }
            fireBuffer.SetData(fireParams);
            cachedInstanceCount = instanceCount;
        }

        void OnDisable()
        {
            if (fireBuffer != null)
                fireBuffer.Release();
            fireBuffer = null;
        }
    } 
}