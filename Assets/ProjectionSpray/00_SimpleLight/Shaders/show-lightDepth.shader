Shader "Unlit/show-lightDepth"
{

	Properties
	{
		_LitPos ("light position", Vector) = (0,0,0,0)
		_LitCol ("light color", Color) = (1,1,1,1)
		_Intensity ("light intensity", Float) = 1
		_Cookie ("spot cokie", 2D) = "white"{}
		_LitDepth ("light depth texture", 2D) = "white"{}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float3 worldPos : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			uniform float4x4 _ProjMatrix, _WorldToLitMatrix;

			half4 _LitPos, _LitCol;
			half _Intensity;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			float3 hsv2rgb(float3 c)
			{
				float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
				return lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y) * c.z;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				///spot-light cookie
				half4 lightSpacePos = mul(_WorldToLitMatrix, half4(i.worldPos, 1.0));
				half lightSpaceDepth = lightSpacePos.z;
				half4 color = half4(hsv2rgb(half3(frac(lightSpaceDepth*0.5), 1, 1)), 1);

				return color;
			}

			ENDCG
		}
	}
}
