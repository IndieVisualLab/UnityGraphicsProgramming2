using System.Linq;
using System.Runtime.InteropServices;
using UnityEngine;


namespace GPUBasedTrails
{
    [RequireComponent(typeof(GPUTrails))]
    public class GPUTrailParticles : MonoBehaviour
    {

        #region Type Define

        public static class CSPARAM
        {
            // kernels
            public const string UPDATE = "Update";
            public const string WRITE_TO_INPUT = "WriteToInput";

            // parameters
            public const string PARTICLE_NUM = "_ParticleNum";
            public const string TIME = "_Time";
            public const string TIME_SCALE = "_TimeScale";
            public const string POSITION_SCALE = "_PositionScale";
            public const string NOISE_SCALE = "_NoiseScale";
            public const string PARTICLE_BUFFER_WRITE = "_ParticleBufferWrite";
            public const string PARTICLE_BUFFER_READ = "_ParticleBufferRead";
            public const string INPUT_BUFFER = "_InputBuffer";
        }

        public struct Particle
        {
            public Vector3 position;
        }

        #endregion

        public ComputeShader cs;
        public float initRadius = 20f;
        public float timeScale = 1f;
        public float positionScale = 1f;
        public float noiseScale = 1f;

        protected ComputeBuffer particleBuffer;
        protected GPUTrails trails;


        protected int particleNum => trails.trailNum;

        void Start()
        {
            trails = GetComponent<GPUTrails>();

            particleBuffer = new ComputeBuffer(particleNum, Marshal.SizeOf(typeof(Particle)));

            particleBuffer.SetData(
                Enumerable.Range(0, particleNum)
                .Select(_ => new Particle() { position = Random.insideUnitSphere * initRadius })
                .ToArray()
            );
        }

        void Update()
        {
            cs.SetInt(CSPARAM.PARTICLE_NUM, particleNum);
            cs.SetFloat(CSPARAM.TIME, Time.time);
            cs.SetFloat(CSPARAM.TIME_SCALE, timeScale);
            cs.SetFloat(CSPARAM.POSITION_SCALE, positionScale);
            cs.SetFloat(CSPARAM.NOISE_SCALE, noiseScale);

            var kernelUpdate = cs.FindKernel(CSPARAM.UPDATE);
            cs.SetBuffer(kernelUpdate, CSPARAM.PARTICLE_BUFFER_WRITE, particleBuffer);

            var updateThureadNum = new Vector3(particleNum, 1f, 1f);
            ComputeShaderUtil.Dispatch(cs, kernelUpdate, updateThureadNum);


            var kernelInput = cs.FindKernel(CSPARAM.WRITE_TO_INPUT);
            cs.SetBuffer(kernelInput, CSPARAM.PARTICLE_BUFFER_READ, particleBuffer);
            cs.SetBuffer(kernelInput, CSPARAM.INPUT_BUFFER, trails.inputBuffer);

            var inputThreadNum = new Vector3(particleNum, 1f, 1f);
            ComputeShaderUtil.Dispatch(cs, kernelInput, inputThreadNum);
        }

        private void OnDestroy()
        {
            particleBuffer.Release();
        }
    }
}