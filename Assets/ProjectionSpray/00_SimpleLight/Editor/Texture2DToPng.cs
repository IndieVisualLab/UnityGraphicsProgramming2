using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

public class Texture2DToPng {
    
    [MenuItem("Assets/tex -> png")]
    public static void TexToPng(){
        var tex = (Texture)Selection.activeObject;
        if (tex == null)
            return;
        TexToPng(tex);
    }

    static void TexToPng(Texture tex){
        var currentActive = RenderTexture.active;
        var rt = new RenderTexture(tex.width, tex.height, 0, RenderTextureFormat.ARGB32);
        rt.Create();
        Graphics.Blit(tex, rt);

        var tex2d = new Texture2D(tex.width, tex.height, TextureFormat.ARGB32, false);
        //Graphics.CopyTexture(rt, tex2d);
        tex2d.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
        tex2d.Apply();

        var data = tex2d.EncodeToPNG();
        string filePath = EditorUtility.SaveFilePanel("Save Texture", "", tex.name + ".png", "png");
        if (filePath.Length > 0)
            File.WriteAllBytes(filePath, data);
        RenderTexture.active = currentActive;

        rt.Release();
        Object.DestroyImmediate(rt);
        Object.DestroyImmediate(tex2d);
    }
}
