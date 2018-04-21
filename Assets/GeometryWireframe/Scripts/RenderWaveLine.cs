using UnityEngine;

[ExecuteInEditMode]
public class RenderWaveLine : MonoBehaviour {

    [Range(2,50)]
    public int vertexNum = 4;

    public Material material;

    private void OnRenderObject()
    {
        material.SetInt("_VertexNum", vertexNum - 1);
        material.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.LineStrip, vertexNum);
    }
}
