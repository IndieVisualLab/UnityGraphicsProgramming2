Shader "Custom/WaveLine"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_ScaleX ("Scale X", Float) = 1
		_ScaleY ("Scale Y", Float) = 1
		_Speed ("Speed",Float) = 1
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
			#pragma target 3.5

			#include "UnityCG.cginc"

			#define PI  3.14159265359

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			float4 _Color;
			int _VertexNum;
			float _ScaleX;
			float _ScaleY;
			float _Speed;

			v2f vert (uint id : SV_VertexID)
			{
				float div = (float)id / _VertexNum;
				float4 pos = float4((div - 0.5) * _ScaleX, sin(div * 2 * PI + _Time.y * _Speed) * _ScaleY, 0, 1);

				v2f o;
				o.vertex = UnityObjectToClipPos(pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}
}
