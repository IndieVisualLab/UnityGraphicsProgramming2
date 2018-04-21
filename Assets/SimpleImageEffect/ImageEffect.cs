using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ImageEffect : ImageEffectBase
{
    #region Field

    protected new Camera camera;

    public DepthTextureMode depthTextureMode;

    #endregion Field

    #region Method

    protected override void Start()
    {
        base.Start();

        this.camera = base.GetComponent<Camera>();
        this.camera.depthTextureMode = this.depthTextureMode;
    }

    protected virtual void OnValidate()
    {
        if (this.camera != null)
        {
            this.camera.depthTextureMode = this.depthTextureMode;
        }
    }

    #endregion Method
}