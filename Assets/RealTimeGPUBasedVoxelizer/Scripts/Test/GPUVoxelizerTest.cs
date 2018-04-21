using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace Voxelizer.Test
{


    [RequireComponent (typeof(MeshFilter))]
    public class GPUVoxelizerTest : MonoBehaviour {

        public Mesh Source { get { return source; } }
        public int Resolution { get { return resolution; } }

        [SerializeField] protected ComputeShader voxelizer;
        [SerializeField] protected Mesh source;
        [SerializeField, Range(16, 256)] protected int resolution = 128;

        void Start () {
            var filter = GetComponent<MeshFilter>();

            var data = GPUVoxelizer.Voxelize(voxelizer, source, resolution);
            var voxels = data.GetData();
            filter.sharedMesh = VoxelMesh.Build(voxels, data.UnitLength);
            data.Dispose();
        }

    }

}


