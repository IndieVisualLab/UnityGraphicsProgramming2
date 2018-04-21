using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSRSubCamera : MonoBehaviour
{
    Camera cam;
    Material mat;
    RenderTexture rt;
    [SerializeField] Shader shader;
    const string depthTex = "_SubCameraDepthTex";
    const string mainTex = "_SubCameraMainTex";

    public int Width { get { return cam.pixelWidth; } }
    public int Height { get { return cam.pixelHeight; } }

    void OnEnable()
    {
        cam = GetComponent<Camera>();
        mat = new Material(shader);
        rt = new RenderTexture(Width, Height, 0, RenderTextureFormat.ARGB32);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, rt, mat, 0);
        Graphics.Blit(src, dst, mat, 1);
        Shader.SetGlobalTexture(mainTex, rt);
        Shader.SetGlobalTexture(depthTex, dst);

    }

    void OnDisable()
    {
        Destroy(mat);
        rt.Release();
    }
}
