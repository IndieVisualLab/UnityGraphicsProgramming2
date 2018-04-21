using UnityEngine;

[ExecuteInEditMode]
public class GeometryOctahedronSphere : MonoBehaviour {

    public Material material;

    [Range(1,3)]
    public int level = 1;

    void OnRenderObject()
    {
        material.SetInt("_Level", level);
        material.SetMatrix("_TRS", transform.localToWorldMatrix);
        material.SetPass(0);
        
        Graphics.DrawProcedural(MeshTopology.Points, 1);
    } 

}
