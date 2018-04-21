Shader "Hidden/FillCrack"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			half4 _MainTex_TexelSize;

			half4 frag (v2f i) : SV_Target
			{
				float2 d = _MainTex_TexelSize.xy;
				half4 col = tex2D(_MainTex, i.uv);
				half4 col0 = tex2D(_MainTex, i.uv - float2(d.x, 0));
				half4 col1 = tex2D(_MainTex, i.uv + float2(d.x, 0));
				half4 col2 = tex2D(_MainTex, i.uv - float2(0, d.y));
				half4 col3 = tex2D(_MainTex, i.uv + float2(0, d.y));

				col.rgb = 0.5 < col.a ?
					col.rgb : (col0.rgb*col0.a + col1.rgb*col1.a + col2.rgb*col2.a + col3.rgb*col3.a) / max(1.0, col0.a + col1.a + col2.a + col3.a);

				return col;
			}
			ENDCG
		}
	}
}
