using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

using UnityEngine;
using UnityEngine.Rendering;
using Random = UnityEngine.Random;

namespace Voxelizer.Demo
{

    public class GPUVoxelParticleSystem : MonoBehaviour {

        #region Shader property keys
        protected const string kVoxelBufferKey = "_VoxelBuffer", kVoxelCountKey = "_VoxelCount";
        protected const string kParticleBufferKey = "_ParticleBuffer", kParticleCountKey = "_ParticleCount";
        #endregion

        [SerializeField] protected ComputeShader voxelizer, particleCompute;
        [SerializeField] protected SkinnedMeshRenderer skinned;
        [SerializeField] protected Material material;
        [SerializeField] protected ShadowCastingMode castShadows = ShadowCastingMode.On;
        [SerializeField] protected bool receiveShadows = true;
        [SerializeField] protected int count = 65000;
        [SerializeField, Range(32, 256)] protected int resolution = 64;

        #region Particle properties

        [SerializeField] protected float speedScaleMin = 2.0f, speedScaleMax = 5.0f;
        [SerializeField] protected Vector3 gravity = Vector3.zero;
        [SerializeField, Range(0.5f, 1f)] protected float decay = 0.92f;

        #endregion

        protected Bounds bounds;
        protected Mesh mesh;
        protected GPUVoxelData data;

        protected Mesh cube;
        protected Kernel setupKer, updateKer;
        protected ComputeBuffer argsBuffer, particleBuffer;

        uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

        #region MonoBehaviour functions

        protected void Start () {
            // sample first
            mesh = new Mesh();
            Sample();

            cube = BuildCube(data.UnitLength);

            args[0] = cube.GetIndexCount(0);
            args[1] = (uint)count;
            argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
            argsBuffer.SetData(args);

            particleBuffer = new ComputeBuffer(count, Marshal.SizeOf(typeof(VoxelParticle_t)));

            setupKer = new Kernel(particleCompute, "Setup");
            updateKer = new Kernel(particleCompute, "Update");

            Setup();
        }
      
        protected void Update () {
            Sample();
            Compute(updateKer, Time.deltaTime);

            material.SetBuffer(kParticleBufferKey, particleBuffer);
            material.SetMatrix("_WorldToLocal", transform.worldToLocalMatrix);
            material.SetMatrix("_LocalToWorld", transform.localToWorldMatrix);
            Graphics.DrawMeshInstancedIndirect(cube, 0, material, new Bounds(Vector3.zero, Vector3.one * 100f), argsBuffer, 0, null, castShadows, receiveShadows);
        }

        protected void OnDrawGizmos()
        {
            Gizmos.color = Color.white;
            Gizmos.DrawWireCube(bounds.center, bounds.size);
        }

        protected void OnDestroy ()
        {
            if(data != null)
            {
                data.Dispose();
                data = null;
            }
            
            if(argsBuffer != null)
            {
                argsBuffer.Release();
                argsBuffer = null;
            }

            if(particleBuffer != null)
            {
                particleBuffer.Release();
                particleBuffer = null;
            }
        }

        #endregion

        void Setup()
        {
            particleCompute.SetBuffer(setupKer.Index, kVoxelBufferKey, data.Buffer);
            particleCompute.SetInt(kVoxelCountKey, data.Buffer.count);
            particleCompute.SetBuffer(setupKer.Index, kParticleBufferKey, particleBuffer);
            particleCompute.SetInt(kParticleCountKey, particleBuffer.count);
            particleCompute.SetInt("_Width", data.Width);
            particleCompute.SetInt("_Height", data.Height);
            particleCompute.SetInt("_Depth", data.Depth);
            particleCompute.SetVector("_Speed", new Vector2(speedScaleMin, speedScaleMax));

            particleCompute.Dispatch(setupKer.Index, particleBuffer.count / (int)setupKer.ThreadX + 1, (int)setupKer.ThreadY, (int)setupKer.ThreadZ);
        }

        void Compute (Kernel kernel, float dt)
        {
            particleCompute.SetBuffer(kernel.Index, kVoxelBufferKey, data.Buffer);
            particleCompute.SetInt(kVoxelCountKey, data.Buffer.count);
            particleCompute.SetBuffer(kernel.Index, kParticleBufferKey, particleBuffer);
            particleCompute.SetInt(kParticleCountKey, particleBuffer.count);

            particleCompute.SetVector("_DT", new Vector2(dt, 1f / dt));
            particleCompute.SetVector("_Gravity", gravity);
            particleCompute.SetFloat("_Decay", decay);

            particleCompute.Dispatch(kernel.Index, particleBuffer.count / (int)kernel.ThreadX + 1, (int)kernel.ThreadY, (int)kernel.ThreadZ);
        }

        protected void Sample()
        {
            skinned.BakeMesh(mesh);

            // expand bounds to contain all bounds of animated meshes
            bounds.Encapsulate(mesh.bounds.min);
            bounds.Encapsulate(mesh.bounds.max);
            
            if(data != null)
            {
                data.Dispose();
                data = null;
            }
			data = GPUVoxelizer.Voxelize(voxelizer, bounds, mesh, resolution);
        }

        #region Build

        Mesh BuildCube(float size)
        {
            var hsize = size * 0.5f;
            var forward = Vector3.forward * hsize;
            var back = -forward;
            var up = Vector3.up * hsize;
            var down = -up;
            var right = Vector3.right * hsize;
            var left = -right;

            // 8 corner vertices for a cube represents one voxel
            var corners = new Vector3[8] {
                forward + left + up,
                back + left + up,
                back + right + up,
                forward + right + up,

                forward + left + down,
                back + left + down,
                back + right + down,
                forward + right + down,
            };

            var vertices = new List<Vector3>();
            var normals = new List<Vector3>();
            var triangles = new List<int>();

            // 6 sides for a cube

            // up
            AddTriangle(corners[0], corners[3], corners[1], up, vertices, normals, triangles);
            AddTriangle(corners[2], corners[1], corners[3], up, vertices, normals, triangles);

            // down
            AddTriangle(corners[4], corners[5], corners[7], down, vertices, normals, triangles);
            AddTriangle(corners[6], corners[7], corners[5], down, vertices, normals, triangles);

            // right
            AddTriangle(corners[7], corners[6], corners[3], right, vertices, normals, triangles);
            AddTriangle(corners[2], corners[3], corners[6], right, vertices, normals, triangles);

            // left
            AddTriangle(corners[5], corners[4], corners[1], left, vertices, normals, triangles);
            AddTriangle(corners[0], corners[1], corners[4], left, vertices, normals, triangles);

            // forward
            AddTriangle(corners[4], corners[7], corners[0], forward, vertices, normals, triangles);
            AddTriangle(corners[3], corners[0], corners[7], forward, vertices, normals, triangles);

            // back
            AddTriangle(corners[6], corners[5], corners[2], back, vertices, normals, triangles);
            AddTriangle(corners[1], corners[2], corners[5], back, vertices, normals, triangles);

            var mesh = new Mesh();
            mesh.SetVertices(vertices);
            mesh.SetNormals(normals);
            mesh.SetIndices(triangles.ToArray(), MeshTopology.Triangles, 0);
            mesh.RecalculateTangents();
            mesh.RecalculateBounds();
            return mesh;
        }

        // set one triangle to a mesh
        protected void AddTriangle(
            Vector3 v0, Vector3 v1, Vector3 v2, Vector3 normal,
            List<Vector3> vertices, List<Vector3> normals, List<int> triangles
        )
        {
            int i = vertices.Count;
            vertices.Add(v0); vertices.Add(v1); vertices.Add(v2);
            var n = normal.normalized;
            normals.Add(n); normals.Add(n); normals.Add(n);
            triangles.Add(i); triangles.Add(i + 1); triangles.Add(i + 2);
        }

        #endregion

    }

    #region define VoxelParticle

    [StructLayout (LayoutKind.Sequential)]
    public struct VoxelParticle_t
    {
        public Vector3 position;
        public Quaternion rotation;
        public Vector3 scale;
        public Vector3 velocity;
        public float speed;
        public float size;
        public float lifetime;
    };

    #endregion

}


