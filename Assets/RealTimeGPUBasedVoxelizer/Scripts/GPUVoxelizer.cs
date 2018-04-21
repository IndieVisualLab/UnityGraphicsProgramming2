using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

using UnityEngine;
using UnityEngine.Rendering;

namespace Voxelizer {

	public class GPUVoxelizer {

        public static GPUVoxelData Voxelize(ComputeShader voxelizer, Mesh mesh, int resolution = 64)
        {
            mesh.RecalculateBounds();
            return Voxelize(voxelizer, mesh.bounds, mesh, resolution);
        }

        public static GPUVoxelData Voxelize(ComputeShader voxelizer, Bounds bounds, Mesh mesh, int resolution = 64)
        {
            // From the specified resolution, calculate the unit length of one voxel
            float maxLength = Mathf.Max(bounds.size.x, Mathf.Max(bounds.size.y, bounds.size.z));
            var unit = maxLength / resolution;

            // half of the unit length
            var hunit = unit * 0.5f;

            // The bounds extended by "half of the unit length constituting one voxel" is defined as the scope of voxelization
            var start = bounds.min - new Vector3(hunit, hunit, hunit);  // Minimum bounds to voxel
            var end = bounds.max + new Vector3(hunit, hunit, hunit);    // Maximum bounds to voxel
            var size = end - start;                                     // Size of bounds to voxel

            // The size of three-dimensional voxel data is determined based on the unit length of the voxel and the scope of voxelization
            int width = Mathf.CeilToInt(size.x / unit);
            int height = Mathf.CeilToInt(size.y / unit);
            int depth = Mathf.CeilToInt(size.z / unit);

            // generate ComputeBuffer representing Voxel_t array
            var voxelBuffer = new ComputeBuffer(width * height * depth, Marshal.SizeOf(typeof(Voxel_t)));
            var voxels = new Voxel_t[voxelBuffer.count];
            voxelBuffer.SetData(voxels); // initialize

            // send voxel data to GPU
			voxelizer.SetVector("_Start", start);
			voxelizer.SetVector("_End", end);
			voxelizer.SetVector("_Size", size);

			voxelizer.SetFloat("_Unit", unit);
			voxelizer.SetFloat("_InvUnit", 1f / unit);
			voxelizer.SetFloat("_HalfUnit", hunit);
			voxelizer.SetInt("_Width", width);
			voxelizer.SetInt("_Height", height);
			voxelizer.SetInt("_Depth", depth);

            // generate ComputeBuffer representing vertex array
			var vertices = mesh.vertices;
			var vertBuffer = new ComputeBuffer(vertices.Length, Marshal.SizeOf(typeof(Vector3)));
			vertBuffer.SetData(vertices);

            // generate ComputeBuffer representing triangle array
			var triangles = mesh.triangles;
			var triBuffer = new ComputeBuffer(triangles.Length, Marshal.SizeOf(typeof(int)));
			triBuffer.SetData(triangles);

            // send mesh data to GPU kernel "SurfaceFront" and "SurfaceBack"
			var surfaceFrontKer = new Kernel(voxelizer, "SurfaceFront");
			voxelizer.SetBuffer(surfaceFrontKer.Index, "_VoxelBuffer", voxelBuffer);
			voxelizer.SetBuffer(surfaceFrontKer.Index, "_VertBuffer", vertBuffer);
			voxelizer.SetBuffer(surfaceFrontKer.Index, "_TriBuffer", triBuffer);

            // set triangle count in a mesh
            var triangleCount = triBuffer.count / 3;
			voxelizer.SetInt("_TriangleCount", triangleCount);

            // execute surface construction in front triangles
			voxelizer.Dispatch(surfaceFrontKer.Index, triangleCount / (int)surfaceFrontKer.ThreadX + 1, (int)surfaceFrontKer.ThreadY, (int)surfaceFrontKer.ThreadZ);

            // execute surface construction in back triangles
			var surfaceBackKer = new Kernel(voxelizer, "SurfaceBack");
			voxelizer.SetBuffer(surfaceBackKer.Index, "_VoxelBuffer", voxelBuffer);
			voxelizer.SetBuffer(surfaceBackKer.Index, "_VertBuffer", vertBuffer);
			voxelizer.SetBuffer(surfaceBackKer.Index, "_TriBuffer", triBuffer);
			voxelizer.Dispatch(surfaceBackKer.Index, triangleCount / (int)surfaceBackKer.ThreadX + 1, (int)surfaceBackKer.ThreadY, (int)surfaceBackKer.ThreadZ);

            // send voxel data to GPU kernel "Volume"
            var volumeKer = new Kernel(voxelizer, "Volume");
            voxelizer.SetBuffer(volumeKer.Index, "_VoxelBuffer", voxelBuffer);

            // execute to fill voxels inside of a mesh
            voxelizer.Dispatch(volumeKer.Index, width / (int)volumeKer.ThreadX + 1, height / (int)volumeKer.ThreadY + 1, (int)surfaceFrontKer.ThreadZ);

			// dispose unnecessary mesh data
			vertBuffer.Release();
			triBuffer.Release();

			return new GPUVoxelData(voxelBuffer, width, height, depth, unit);
        }

	}

}

