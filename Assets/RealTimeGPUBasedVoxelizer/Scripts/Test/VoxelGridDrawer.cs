using System.Collections;
using System.Collections.Generic;

using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace Voxelizer.Test
{

    public class VoxelGridDrawer : MonoBehaviour {

        [SerializeField] protected CPUVoxelizerTest test;

        [SerializeField] protected bool drawGrid = true, drawRay = false;

        protected void Start ()
        {
        }

        protected void OnDrawGizmos ()
        {
            var bounds = test.Source.bounds;
            float maxLength = Mathf.Max(bounds.size.x, Mathf.Max(bounds.size.y, bounds.size.z));
            var unit = maxLength / test.Resolution;

            Gizmos.matrix = transform.localToWorldMatrix;
            if (drawGrid) {
                DrawGridGizmos(bounds, unit);
            }
            if (drawRay) {
                DrawRayGizmos(bounds, unit);
            }
        }

        protected void DrawGridGizmos (Bounds bounds, float unit)
        {
            var start = bounds.min;
            var end = bounds.max;

            var iw = Mathf.CeilToInt((end.x - start.x) / unit);
            var ih = Mathf.CeilToInt((end.y - start.y) / unit);
            var id = Mathf.CeilToInt((end.z - start.z) / unit);

            for(int z = 0; z <= id; z++)
            {
                for(int y = 0; y <= ih; y++)
                {
                    var p0 = new Vector3(0, y, z) * unit + start;
                    var p1 = new Vector3(iw, y, z) * unit + start;
                    Gizmos.DrawLine(p0, p1);
                }
            }

            for(int z = 0; z <= id; z++)
            {
                for(int x = 0; x <= iw; x++)
                {
                    var p0 = new Vector3(x, 0, z) * unit + start;
                    var p1 = new Vector3(x, ih, z) * unit + start;
                    Gizmos.DrawLine(p0, p1);
                }
            }

            for(int y = 0; y <= ih; y++)
            {
                for(int x = 0; x <= iw; x++)
                {
                    var p0 = new Vector3(x, y, 0) * unit + start;
                    var p1 = new Vector3(x, y, id) * unit + start;
                    Gizmos.DrawLine(p0, p1);
                }
            }

        }

        protected void DrawRayGizmos (Bounds bounds, float unit)
        {
            Gizmos.color = Color.red;
            var start = bounds.min;
            var end = bounds.max;
            var hunit = unit * 0.5f;

            var ex = start.x + Mathf.CeilToInt((end.x - start.x) / unit) * unit - unit;
            var ey = start.y + Mathf.CeilToInt((end.y - start.y) / unit) * unit - unit;
            var dz = Mathf.CeilToInt((end.z - start.z) / unit) * unit;
            for(float y = start.y; y <= ey; y += unit) {
                for(float x = start.x; x <= ex; x += unit) {
                    var ray = new Ray(new Vector3(x + hunit, y + hunit, start.z), Vector3.forward);
                    Gizmos.DrawLine(ray.origin, ray.origin + ray.direction * dz);
                }
            }
        }

    }

}


