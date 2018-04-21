using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : MonoBehaviour
{
    Material mat;
    RenderTexture rt;
    [SerializeField] Shader shader;
    [SerializeField] int blurNum = 3;

    void OnEnable()
    {
        mat = new Material(shader);
    }

    void OnDisable()
    {
        Destroy(mat);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        var rt = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);

        for (int i = 0; i < blurNum; i++)
        {
            Graphics.Blit(src, rt, mat, 0);
            Graphics.Blit(rt, src, mat, 1);
        }

        Graphics.Blit(src, dst);

        RenderTexture.ReleaseTemporary(rt);
    }
}
