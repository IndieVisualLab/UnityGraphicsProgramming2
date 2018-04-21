using System.Collections;
using System.Collections.Generic;

using UnityEngine;
using UnityEngine.Rendering;

namespace Voxelizer
{

    public class VoxelMesh {

        public static Mesh Build (Voxel_t[] voxels, float size)
        {
            var hsize = size * 0.5f;
            var forward = Vector3.forward * hsize;
            var back = -forward;
            var up = Vector3.up * hsize;
            var down = -up;
            var right = Vector3.right * hsize;
            var left = -right;

            var vertices = new List<Vector3>();
            var normals = new List<Vector3>();
            var triangles = new List<int>();

            for(int i = 0, n = voxels.Length; i < n; i++)
            {
                if (voxels[i].fill == 0) continue;

                var p = voxels[i].position;

                // 8 corner vertices for a cube represents one voxel
                var corners = new Vector3[8] {
                    p + forward + left + up,
                    p + back + left + up,
                    p + back + right + up,
                    p + forward + right + up,

                    p + forward + left + down,
                    p + back + left + down,
                    p + back + right + down,
                    p + forward + right + down,
                };

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
                AddTriangle(corners[6], corners[5], corners[2], forward, vertices, normals, triangles);
                AddTriangle(corners[1], corners[2], corners[5], forward, vertices, normals, triangles);
            }

            var mesh = new Mesh();
            mesh.SetVertices(vertices);

            // set 32 bit index format if vertex count is over 16 bit limit
            mesh.indexFormat = (vertices.Count <= 65535) ? IndexFormat.UInt16 : IndexFormat.UInt32;
            mesh.SetNormals(normals);
            mesh.SetIndices(triangles.ToArray(), MeshTopology.Triangles, 0);
            mesh.RecalculateBounds();
            return mesh;
        }

        // set one triangle to a mesh
        protected static void AddTriangle(
            Vector3 v0, Vector3 v1, Vector3 v2, Vector3 normal,
            List<Vector3> vertices, List<Vector3> normals, List<int> triangles
        )
        {
            int i = vertices.Count;
            vertices.Add(v0); vertices.Add(v1); vertices.Add(v2);
            normals.Add(normal); normals.Add(normal); normals.Add(normal);
            triangles.Add(i); triangles.Add(i + 1); triangles.Add(i + 2);
        }

    }

}


