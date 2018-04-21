using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Voxelizer.Test {

	public class BoundingBoxDrawer : MonoBehaviour {

		[SerializeField] protected Mesh mesh;
		[SerializeField] protected Color color = Color.white;
		[SerializeField] protected bool useThickness = true;
		[SerializeField] protected float thickness = 0.001f;

		protected void OnDrawGizmos () {
			if(mesh == null) return;

			var bounds = mesh.bounds;
			Gizmos.matrix = transform.localToWorldMatrix;
			Gizmos.color = color;
			if(useThickness) {
				DrawThicknessWireCube(bounds.center, bounds.size, thickness);
			} else {
				Gizmos.DrawWireCube(bounds.center, bounds.size);
			}
		}

		void DrawThicknessWireCube(Vector3 center, Vector3 size, float thickness) {
			var hsize = size * 0.5f;
			var p0 = center + new Vector3(-hsize.x,  hsize.y, -hsize.z);
			var p1 = center + new Vector3(-hsize.x,  hsize.y,  hsize.z);
			var p2 = center + new Vector3( hsize.x,  hsize.y,  hsize.z);
			var p3 = center + new Vector3( hsize.x,  hsize.y, -hsize.z);
			var p4 = center + new Vector3(-hsize.x, -hsize.y, -hsize.z);
			var p5 = center + new Vector3(-hsize.x, -hsize.y,  hsize.z);
			var p6 = center + new Vector3( hsize.x, -hsize.y,  hsize.z);
			var p7 = center + new Vector3( hsize.x, -hsize.y, -hsize.z);
			Gizmos.DrawCube((p0 + p1) * 0.5f, new Vector3(thickness, thickness, size.z));
			Gizmos.DrawCube((p1 + p2) * 0.5f, new Vector3(size.x, thickness, thickness));
			Gizmos.DrawCube((p2 + p3) * 0.5f, new Vector3(thickness, thickness, size.z));
			Gizmos.DrawCube((p3 + p0) * 0.5f, new Vector3(size.x, thickness, thickness));

			Gizmos.DrawCube((p0 + p4) * 0.5f, new Vector3(thickness, size.y, thickness));
			Gizmos.DrawCube((p1 + p5) * 0.5f, new Vector3(thickness, size.y, thickness));
			Gizmos.DrawCube((p2 + p6) * 0.5f, new Vector3(thickness, size.y, thickness));
			Gizmos.DrawCube((p3 + p7) * 0.5f, new Vector3(thickness, size.y, thickness));

			Gizmos.DrawCube((p4 + p5) * 0.5f, new Vector3(thickness, thickness, size.z));
			Gizmos.DrawCube((p5 + p6) * 0.5f, new Vector3(size.x, thickness, thickness));
			Gizmos.DrawCube((p6 + p7) * 0.5f, new Vector3(thickness, thickness, size.z));
			Gizmos.DrawCube((p7 + p4) * 0.5f, new Vector3(size.x, thickness, thickness));
		}

	}

}

