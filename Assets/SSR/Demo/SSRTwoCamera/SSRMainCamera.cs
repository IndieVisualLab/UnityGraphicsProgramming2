using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class SSRMainCamera : MonoBehaviour
{
    Camera cam;
    Material mat;
    [SerializeField] Shader shader;

    void OnEnable()
    {
        cam = GetComponent<Camera>();
        mat = new Material(shader);

       

    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Matrix4x4 view = cam.worldToCameraMatrix;
        Matrix4x4 proj = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false);
        Matrix4x4 vp = proj * view;
        mat.SetMatrix("_ViewProj", vp);
        mat.SetMatrix("_InvViewProj", vp.inverse);
        Graphics.Blit(src, dst, mat);
    }

    void OnDisable()
    {
        Destroy(mat);
    }
}
