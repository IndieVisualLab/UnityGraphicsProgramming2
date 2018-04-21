using UnityEngine;

[ExecuteInEditMode]
public class CompareMatrix : MonoBehaviour {

    public float fov = 30f;
    public float near = 0.01f;
    public float far = 1000f;

    public Matrix4x4 perseMatrix;
    public Matrix4x4 cameraMatrix;

    new Camera camera;

    private void Start()
    {
        camera = GetComponent<Camera>();
        camera.targetTexture = new RenderTexture(512, 512, 16);
    }

    private void Update()
    {
        perseMatrix = Matrix4x4.Perspective(fov, 1f, near, far);
        camera.fieldOfView = fov;
        camera.nearClipPlane = near;
        camera.farClipPlane = far;
        cameraMatrix = camera.projectionMatrix;
    }
}
