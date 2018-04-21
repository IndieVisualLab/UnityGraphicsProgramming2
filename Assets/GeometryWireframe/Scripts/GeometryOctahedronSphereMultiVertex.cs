using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GeometryOctahedronSphereMultiVertex : MonoBehaviour {

    [Range(1, 9)]
    public int level = 1;
    public Material renderMaterial;

    void OnRenderObject()
    {
        Quaternion q = transform.rotation;
        Vector4 rot = new Vector4(q.x, q.y, q.z, q.w);

        renderMaterial.SetVector("_Rotation", rot);
        renderMaterial.SetInt("_Level", level);
        renderMaterial.SetPass(0);
        
        Graphics.DrawProcedural(MeshTopology.Points, 8);
    } 

}
