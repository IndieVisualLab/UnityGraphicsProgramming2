using UnityEngine;

[ExecuteInEditMode]
public class SpotLightWithShadow : MonoBehaviour
{
    static MaterialPropertyBlock mpb;

    public Renderer[] targetRenderers;
    public float intensity = 1f;
    public Color color = Color.white;
    [Range(0.01f, 90f)] public float angle = 30f;
    public float range = 10f;
    public Texture cookie;
    public int shadowMapResolution = 1024;

    Shader depthRenderShader { get { return Shader.Find("Unlit/depthRender"); } }

    new Camera camera
    {
        get
        {
            if (_c == null)
            {
                _c = GetComponent<Camera>();
                if (_c == null)
                    _c = gameObject.AddComponent<Camera>();
                depthOutput = new RenderTexture(shadowMapResolution, shadowMapResolution, 16, RenderTextureFormat.RFloat);
                depthOutput.wrapMode = TextureWrapMode.Clamp;
                depthOutput.Create();
                _c.targetTexture = depthOutput;
                _c.SetReplacementShader(depthRenderShader, "RenderType");
                _c.clearFlags = CameraClearFlags.Nothing;
                _c.nearClipPlane = 0.01f;
                _c.enabled = false;
            }
            return _c;
        }
    }
    Camera _c;
    RenderTexture depthOutput;

    void Update()
    {
        if (mpb == null)
            mpb = new MaterialPropertyBlock();

        var currentRt = RenderTexture.active;
        RenderTexture.active = depthOutput;
        GL.Clear(true, true, Color.white * camera.farClipPlane);
        camera.fieldOfView = angle;
        camera.nearClipPlane = 0.01f;
        camera.farClipPlane = range;
        camera.Render();
        RenderTexture.active = currentRt;

        var projMatrix = camera.projectionMatrix;
        var worldToLightMatrix = transform.worldToLocalMatrix;

        foreach (var r in targetRenderers)
        {
            r.GetPropertyBlock(mpb);
            mpb.SetVector("_LitPos", transform.position);
            mpb.SetFloat("_Intensity", intensity);
            mpb.SetColor("_LitCol", color);
            mpb.SetMatrix("_WorldToLitMatrix", worldToLightMatrix);
            mpb.SetMatrix("_ProjMatrix", projMatrix);
            mpb.SetTexture("_Cookie", cookie);
            mpb.SetTexture("_LitDepth", depthOutput);
            r.SetPropertyBlock(mpb);
        }
    }

    private void OnDestroy()
    {
        if (depthOutput != null)
            depthOutput.Release();
    }
}
