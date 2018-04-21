Shader "ImageEffectBase_03"
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
            float4    _MainTex_TexelSize;

            fixed4 frag(v2f_img input) : SV_Target
            {
                float4 color = tex2D(_MainTex, input.uv);

                color += tex2D(_MainTex, input.uv + float2(_MainTex_TexelSize.x, 0));
                color += tex2D(_MainTex, input.uv - float2(_MainTex_TexelSize.x, 0));
                color += tex2D(_MainTex, input.uv + float2(0, _MainTex_TexelSize.y));
                color += tex2D(_MainTex, input.uv - float2(0, _MainTex_TexelSize.y));

                color = color / 5;

                return color;
            }

            ENDCG
        }
    }
}