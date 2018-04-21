using System;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using Debug = UnityEngine.Debug;

namespace Voxelizer.Test
{

    public class Benchmark : MonoBehaviour {

        [SerializeField] protected ComputeShader voxelizer;
        [SerializeField] protected Mesh source;
        [SerializeField, Range(16, 256)] protected int resolution = 256;
        [SerializeField] protected int iterations = 30;

        void Start () {
            Measure(() => {
                List<Voxel_t> voxels;
                float unit;
                CPUVoxelizer.Voxelize(source, resolution, out voxels, out unit);
            }, iterations);

            Measure(() => {
                var data = GPUVoxelizer.Voxelize(voxelizer, source, resolution);
                data.Dispose();
            }, iterations);
        }

        void Measure(Action act, int iterations)
        {
            GC.Collect();

            // run once outside of loop to avoid initialization costs
            act.Invoke();
            Stopwatch sw = Stopwatch.StartNew();
            for (int i = 0; i < iterations; i++)
            {
                act.Invoke();
            }
            sw.Stop();

            Debug.Log((sw.ElapsedMilliseconds / iterations).ToString());
        }

    }

}


