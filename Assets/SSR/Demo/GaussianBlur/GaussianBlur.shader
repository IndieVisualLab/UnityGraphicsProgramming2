Shader "Unlit/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _BlurOffset ("BlurOffset", float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _MainTex_TexelSize;
 
        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        float4 x_blur (v2f i) : SV_Target
        {
            float weight [5] = { 0.22702703, 0.19459459, 0.12162162, 0.05405405, 0.01621622 };
            float offset [5] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
            float2 size = _MainTex_TexelSize;
            fixed4 col = tex2D(_MainTex, i.uv) * weight[0];

            for(int j=1; j<5; j++)
            {
                col += tex2D(_MainTex, i.uv + float2(offset[j], 0) * size) * weight[j];
                col += tex2D(_MainTex, i.uv - float2(offset[j], 0) * size) * weight[j];
            }
            return col;
        }

        float4 y_blur (v2f i) : SV_Target
        {
            float weight [5] = { 0.22702703, 0.19459459, 0.12162162, 0.05405405, 0.01621622 };
            float offset [5] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
            float2 size = _MainTex_TexelSize;
            fixed4 col = tex2D(_MainTex, i.uv) * weight[0];

            for(int j=1; j<5; j++)
            {
                col += tex2D(_MainTex, i.uv + float2(0, offset[j]) * size) * weight[j];
                col += tex2D(_MainTex, i.uv - float2(0, offset[j]) * size) * weight[j];
            }

            return col;
        }

        ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment x_blur
			ENDCG
		}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment y_blur
            ENDCG
        }
	}
}
