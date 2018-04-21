using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace Voxelizer.Test
{


    [RequireComponent (typeof(MeshFilter))]
    public class CPUVoxelizerTest : MonoBehaviour {

        public Mesh Source { get { return source; } }
        public int Resolution { get { return resolution; } }

        [SerializeField] protected Mesh source;
        [SerializeField, Range(16, 256)] protected int resolution = 32;
        [SerializeField] protected bool surfaceOnly = false;

        void Start () {
            var filter = GetComponent<MeshFilter>();
            filter.sharedMesh = Voxelize(source);
        }

        Mesh Voxelize (Mesh source)
        {
            List<Voxel_t> voxels;
            float size;
			CPUVoxelizer.Voxelize(source, resolution, out voxels, out size, surfaceOnly);
            return VoxelMesh.Build(voxels.ToArray(), size);
        }

    }

}


