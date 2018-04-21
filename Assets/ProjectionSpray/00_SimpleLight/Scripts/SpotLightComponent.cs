using UnityEngine;

[ExecuteInEditMode]
public class SpotLightComponent : MonoBehaviour
{
    static MaterialPropertyBlock mpb;

    public Renderer targetRenderer;
    public float intensity = 1f;
    public Color color = Color.white;
    [Range(0.01f, 90f)] public float angle = 30f;
    public float range = 10f;
    public Texture cookie;

    void Update()
    {
        if (targetRenderer == null)
            return;
        if (mpb == null)
            mpb = new MaterialPropertyBlock();

        var projMatrix = Matrix4x4.Perspective(angle, 1f, 0f, range);
        var worldToLightMatrix = transform.worldToLocalMatrix;

        targetRenderer.GetPropertyBlock(mpb);
        mpb.SetVector("_LitPos", transform.position);
        mpb.SetFloat("_Intensity", intensity);
        mpb.SetColor("_LitCol", color);
        mpb.SetMatrix("_WorldToLitMatrix", worldToLightMatrix);
        mpb.SetMatrix("_ProjMatrix", projMatrix);
        mpb.SetTexture("_Cookie", cookie);
        targetRenderer.SetPropertyBlock(mpb);
    }
}
