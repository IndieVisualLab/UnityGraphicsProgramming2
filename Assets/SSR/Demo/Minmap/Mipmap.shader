Shader "Unlit/Mipmap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _LOD ("LOD", int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _LOD;

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

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return tex2Dlod(_MainTex, float4(i.uv, 0, _LOD));
			}
			ENDCG
		}
	}
}
