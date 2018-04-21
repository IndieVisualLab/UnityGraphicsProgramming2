Shader "Unlit/SSRMainCamera"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}

	SubShader
	{
	Blend Off
	ZTest Always
	ZWrite Off
	Cull Off

	CGINCLUDE

	#include "UnityCG.cginc"

		// from main camera
		sampler2D _MainTex;
	    sampler2D _CameraGBufferTexture1;
		sampler2D _CameraGBufferTexture2;
		sampler2D _CameraDepthTexture;
		float4 _MainTex_ST;
		float4x4 _InvViewProj;
		float4x4 _ViewProj;

		// from sub camera
		sampler2D _SubCameraDepthTex;
		sampler2D _SubCameraMainTex;

		struct appdata
		{
			float4 vertex : POSITION;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float4 screen : TEXCOORD0;
		};


		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.screen = ComputeScreenPos(o.vertex);
			return o;
		}

		float4 reflection(v2f i) : SV_Target
		{
		  float2 uv = i.screen.xy / i.screen.w;
		  float2 uvCenter = 2.0 * uv - 1.0;
		  float4 col = tex2D(_MainTex, uv);
		  float smooth = tex2D(_CameraGBufferTexture1, uv).w;

		  float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
		  if (depth <= 0.0) return col;

		  float4 pos = mul(_InvViewProj, float4(uvCenter, depth, 1.0));
		  pos /= pos.w;

		  float3 camDir = normalize(pos - _WorldSpaceCameraPos);
		  float3 normal = tex2D(_CameraGBufferTexture2, uv) * 2.0 - 1.0;
		  float3 refDir = reflect(camDir, normal);

		  float thickness = 0.003;
		  float3 step = 0.05 * normal;

		  for (int n = 1; n <= 100; ++n)
		  {
			float3 ray = n * step;
			float3 rayPos = pos + ray;
			float4 vpPos = mul(_ViewProj, float4(rayPos, 1.0));
			float2 rayUv = vpPos.xy / vpPos.w * 0.5 + 0.5;
			float rayDepth = vpPos.z / vpPos.w;
			float subCameraDepth = SAMPLE_DEPTH_TEXTURE(_SubCameraDepthTex, rayUv);

			if (rayDepth < subCameraDepth && rayDepth + thickness > subCameraDepth)
			{
			  float sign = -1.0;
			  for (int m = 1; m <= 4; ++m)
			  {
				 rayPos += sign * pow(0.5, m) * step;
				 vpPos = mul(_ViewProj, float4(rayPos, 1.0));
				 rayUv = vpPos.xy / vpPos.w * 0.5 + 0.5;
				 rayDepth = vpPos.z / vpPos.w;
				 subCameraDepth = SAMPLE_DEPTH_TEXTURE(_SubCameraDepthTex, rayUv);
				 sign = rayDepth - subCameraDepth < 0 ? -1 : 1;
			  }
			  col = tex2D(_SubCameraMainTex, rayUv);
			}
		  }
		  return col * smooth + tex2D(_MainTex, uv) * (1 - smooth);
		}
		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment reflection
			ENDCG
		}
	}
}
