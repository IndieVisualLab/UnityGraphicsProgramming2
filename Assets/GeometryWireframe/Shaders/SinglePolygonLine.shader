Shader "Custom/Single Polygon Line"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Scale ("Scale", Float) = 1
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
			#pragma geometry geom	// Geometry Shader の定義
			#pragma fragment frag
			#pragma target 4.0

			#include "UnityCG.cginc"

			#define PI  3.14159265359

			struct app_data {
				float4 vertex:POSITION;
				uint id : SV_VertexID;
			};

			// 出力構造体
			struct Output
			{
				float4 pos : SV_POSITION;
			};

			float4 _Color;
			int _VertexNum;
			float _Scale;
			float _Speed;
			float4x4 _TRS;

			Output vert (app_data v)
			{
				Output o;
				o.pos = mul(_TRS, float4(0, 0, 0, 1));
				return o;
			}
			
			// ジオメトリシェーダ
			[maxvertexcount(65)]
			void geom(point Output input[1], inout LineStream<Output> outStream)
			{
				Output o;
				float rad = 2.0 * PI / (float)_VertexNum;
				float time = _Time.y * _Speed;

				float4 pos;

				for (int i = 0; i <= _VertexNum; i++) {
					pos.x = cos(i * rad + time) * _Scale;
					pos.y = sin(i * rad + time) * _Scale;
					pos.z = 0;
					pos.w = 0;
					o.pos = UnityObjectToClipPos(input[0].pos + pos);

					outStream.Append(o);
				}

				outStream.RestartStrip();
			}

			fixed4 frag (Output i) : SV_Target
			{
				return _Color;
			}
			ENDCG
		}
	}
}
