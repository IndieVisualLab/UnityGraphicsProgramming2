Shader "TheStudyOfProceduralNoise/ClassicPerlinNoise2D"
{
	Properties
	{
		_NoiseFrequency("Noise Frequency", Float) = 1.0
		_NoiseSpeed    ("Noise Speed",     Float) = 1.0
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	#include "ProceduralNoise/ClassicPerlinNoise2D.cginc"

	uniform float _NoiseFrequency;
	uniform float _NoiseSpeed;

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv     : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv     : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	v2f vert(appdata v)
	{
		v2f o = (v2f)0;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv     = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = (fixed4)0.0;
		float n = 0.5 + 0.5 * perlinNoise(float2(i.uv.xy * _NoiseFrequency));
		col.rgb = n;
		col.a   = 1.0;
		return col;
	}
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Cull Back
		ZWrite On

		Pass
		{
			CGPROGRAM
			#pragma vertex   vert
			#pragma fragment frag
			ENDCG
		}
	}
}
