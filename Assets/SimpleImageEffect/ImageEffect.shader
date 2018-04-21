Shader "ImageEffect"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        
        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma vertex vert_img
            #pragma fragment frag

            sampler2D _MainTex;
            sampler2D _CameraDepthNormalsTexture;

            fixed4 frag(v2f_img input) : SV_Target
            {
                float4 color = tex2D(_MainTex, input.uv);
                float3 normal;
                float  depth;

                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, input.uv), depth, normal);

                depth = Linear01Depth(depth);
                return fixed4(depth, depth, depth, 1);

                return fixed4(normal.xyz, 1);
            }

            ENDCG
        }
    }
}