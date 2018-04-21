using UnityEngine;

[ExecuteInEditMode]
public class SinglePolygon2D : MonoBehaviour {

    [Range(2, 64)]
    public int vertexNum = 3;

    public Material material;

    private void OnRenderObject()
    {
        material.SetInt("_VertexNum", vertexNum);
        material.SetMatrix("_TRS", transform.localToWorldMatrix);
        material.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Points, 1);
    }
}
