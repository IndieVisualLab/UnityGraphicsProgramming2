using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace Voxelizer.Test {

	public class SATTest : MonoBehaviour {

		[SerializeField] protected Bounds aabb;
		[SerializeField] protected Vector3 a = Vector3.left, b = Vector3.up, c = Vector3.right;
		[SerializeField] protected float projSize = 0.1f;
		[SerializeField] protected bool intersection;

		void OnDrawGizmos () {
	
			Gizmos.color = Color.red;
			Gizmos.DrawWireCube(aabb.center, aabb.size);

			var extents = aabb.extents;

			var v0 = a - aabb.center;
			var v1 = b - aabb.center;
			var v2 = c - aabb.center;
			var f0 = v1 - v0;

			Gizmos.color = Color.gray;
			Gizmos.DrawLine(v0, v1);
			Gizmos.DrawLine(v1, v2);
			Gizmos.DrawLine(v2, v0);

			/*
			Gizmos.color = Color.blue;
			Gizmos.DrawLine(aabb.center, v0);
			Gizmos.DrawLine(aabb.center, v1);
			Gizmos.DrawLine(aabb.center, v2);
			*/

			var axis = Vector3.Cross(Vector3.right, f0).normalized;

			Gizmos.color = Color.black;
			Gizmos.DrawLine(- axis * 1000f, axis * 1000f);

			var p0 = Vector3.Dot(v0, axis);
			var p1 = Vector3.Dot(v1, axis);
			var p2 = Vector3.Dot(v2, axis);

			// Gizmos.DrawLine(aabb.center, aabb.center + axis * 100f);
			Gizmos.color = Color.blue;
			Gizmos.DrawSphere(aabb.center + axis * p0, projSize);
			Gizmos.DrawSphere(aabb.center + axis * p1, projSize);
			Gizmos.DrawSphere(aabb.center + axis * p2, projSize);
			Gizmos.DrawLine(aabb.center + axis * p0, aabb.center + axis * p1);
			Gizmos.DrawLine(aabb.center + axis * p1, aabb.center + axis * p2);
			Gizmos.DrawLine(aabb.center + axis * p2, aabb.center + axis * p0);

			#if UNITY_EDITOR
			Handles.Label(aabb.center + axis * p0, p0.ToString("0.00"));
			Handles.Label(aabb.center + axis * p2, p2.ToString("0.00"));
			#endif

			float r = extents.x * Mathf.Abs(axis.x) + extents.y * Mathf.Abs(axis.y) + extents.z * Mathf.Abs(axis.z);

			float minP = Mathf.Min(p0, p1, p2);
			float maxP = Mathf.Max(p0, p1, p2);
			intersection = !((maxP < -r) || (r < minP));

			Gizmos.color = intersection ? Color.green : Color.red;
			Gizmos.DrawSphere(aabb.center + axis * r, projSize);

			float minX = aabb.min.x, minY = aabb.min.y, minZ = aabb.min.z;
			float maxX = aabb.max.x, maxY = aabb.max.y, maxZ = aabb.max.z;
			var corners = new Vector3[8] {
				new Vector3(minX, minY, minZ),
				new Vector3(minX, minY, maxZ),
				new Vector3(maxX, minY, maxZ),
				new Vector3(maxX, minY, minZ),
				new Vector3(minX, maxY, minZ),
				new Vector3(minX, maxY, maxZ),
				new Vector3(maxX, maxY, maxZ),
				new Vector3(maxX, maxY, minZ)
			};
			float minR = Vector3.Dot(axis, corners[0]);
			float maxR = minR;
			for(int i = 1, n = corners.Length; i < n; i++) {
				var dr = Vector3.Dot(axis, corners[i]);
				minR = Mathf.Min(dr, minR);
				maxR = Mathf.Max(dr, maxR);
			}
			Gizmos.DrawSphere(aabb.center + axis * minR, projSize);
			Gizmos.DrawSphere(aabb.center + axis * maxR, projSize);
			Gizmos.DrawLine(
				aabb.center + axis * minR, 
				aabb.center + axis * maxR
			);

			#if UNITY_EDITOR
			Handles.Label(aabb.center + axis * minR, minR.ToString("0.00"));
			Handles.Label(aabb.center + axis * maxR, maxR.ToString("0.00"));
			#endif

			// Debug.Log(p0.ToString("0.00") + ", " + p1.ToString("0.00") + ", "  + p2.ToString("0.00") );
			// Debug.Log(r.ToString("0.00") + " : " + intersection);

		}

	}
		
}

