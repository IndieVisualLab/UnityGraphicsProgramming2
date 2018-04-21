Shader "TheStudyOfProceduralNoise/PseudoRandom2D"
{
	Properties
	{
	}
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

	// 疑似乱数生成
	float2 pseudoRandom(float2 v)
	{
		v = float2(dot(v, float2(127.1, 311.7)), dot(v, float2(269.5, 183.3)));
		return -1.0 + 2.0 * frac(sin(v) * 43758.5453123);
	}

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = (fixed4)(0.5 + 0.5 * pseudoRandom(i.uv.xy).x);
		return col;
	}
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
