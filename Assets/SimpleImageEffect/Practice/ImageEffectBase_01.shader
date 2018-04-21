Shader "ImageEffectBase_01"
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

            fixed4 frag(v2f_img input) : SV_Target
            {
                float4 color = tex2D(_MainTex, input.uv);

                color.rgb = input.uv.x < 0.5 ? 1 - color.rgb : color.rgb;
                //color.rgb = input.uv.y < 0.5 ? 1 - color.rgb : color.rgb;
                
                return color;
            }

            ENDCG
        }
    }
}