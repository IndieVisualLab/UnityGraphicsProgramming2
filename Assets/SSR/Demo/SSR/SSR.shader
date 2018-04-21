Shader "ImageEffect/SSR"
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

		int _ViewMode;
		int _MaxLOD;
		int _MaxLoop;
		float _Thickness;
		float _RayLenCoeff;

		float _BaseRaise;
		float4x4 _InvViewProj;
		float4x4 _ViewProj;

		sampler2D _MainTex;
		float4 _MainTex_ST;

		float _ReflectionRate;
		float _BlurThreshold;

		sampler2D _ReflectionTexture;
		float4 _ReflectionTexture_TexelSize;
		sampler2D _PreAccumulationTexture;
		sampler2D _AccumulationTexture;

		sampler2D _CameraGBufferTexture0; // rgb: diffuse,  a: occlusion
		sampler2D _CameraGBufferTexture1; // rgb: specular, a: smoothness
		sampler2D _CameraGBufferTexture2; // rgb: normal,   a: unused
		sampler2D _CameraGBufferTexture3; // rgb: emission, a: unused
		sampler2D _CameraDepthTexture;
		sampler2D _CameraDepthMipmap;


		float ComputeDepth(float4 clippos)
		{
			#if defined(SHADER_TARGET_GLSL) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
			return (clippos.z / clippos.w) * 0.5 + 0.5;
			#else
			return clippos.z / clippos.w;
			#endif
		}

		float rand(float2 co)
		{
			return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
		}


		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
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

		v2f vert_fullscreen(appdata v)
		{
			v2f o;
			o.vertex = v.vertex;
			o.screen = ComputeScreenPos(o.vertex);
			return o;
		}

		float4 outDepthTexture(v2f i) : SV_Target
		{
			return tex2D(_CameraDepthTexture, i.screen);
		}

		float4 reflection(v2f i) : SV_Target
		{
			float2 uv = i.screen.xy / i.screen.w;
			float4 col = tex2D(_MainTex, uv);
			float4 refcol = tex2D(_MainTex, uv);
			float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
			float smooth = tex2D(_CameraGBufferTexture1, uv).w;
			if (depth <= 0.0) return tex2D(_MainTex, uv);

			float2 screenpos = 2.0 * uv - 1.0;
			float4 pos = mul(_InvViewProj, float4(screenpos, depth, 1.0));
			pos /= pos.w;

			float3 cam = normalize(pos - _WorldSpaceCameraPos);
			float3 nor = tex2D(_CameraGBufferTexture2, uv) * 2.0 - 1.0;
			float3 ref = reflect(cam, nor);

			int lod = 0;
			int calc = 0;
			float3 ray = pos;

			[loop]
			for (int n = 1; n <= _MaxLoop; n++)
			{
				float3 step = ref * _RayLenCoeff * (lod + 1);
				ray += step * (1 + rand(uv + _Time.x) * (1 - smooth));

				float4 rayScreen = mul(_ViewProj, float4(ray, 1.0));
				float2 rayUV = rayScreen.xy / rayScreen.w * 0.5 + 0.5;
				float  rayDepth = ComputeDepth(rayScreen);
				float  worldDepth = (lod == 0) ? SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, rayUV) : tex2Dlod(_CameraDepthMipmap, float4(rayUV, 0, lod)) + _BaseRaise * lod;

				if (max(abs(rayUV.x - 0.5), abs(rayUV.y - 0.5)) > 0.5) break;


				if (rayDepth < worldDepth)
				{
					if (lod == 0)
					{
						if (rayDepth + _Thickness > worldDepth)
						{
							float sign = -1.0;
							for (int m = 1; m <= 8; ++m)
							{
								ray += sign * pow(0.5, m) * step;
								rayScreen = mul(_ViewProj, float4(ray, 1.0));
								rayUV = rayScreen.xy / rayScreen.w * 0.5 + 0.5;
								rayDepth = ComputeDepth(rayScreen);
								worldDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, rayUV);
								sign = (rayDepth < worldDepth) ? -1 : 1;
							}
							refcol = tex2D(_MainTex, rayUV);
						}
						break;
					}
					else
					{
						ray -= step;
						lod--;
					}
				}
				else if (n <= _MaxLOD)
				{
					lod++;
				}

				calc = n;
                
                if(length(ray - pos) > 15.0) break;
			}

			if (_ViewMode == 1) return float4((nor.xyz), 1);
			if (_ViewMode == 2) return float4((ref.xyz), 1);
			if (_ViewMode == 3) return float4(1, 1, 1, 1) * calc / _MaxLoop;
			if (_ViewMode == 4) return float4(1, 1, 1, 1) * tex2Dlod(_CameraDepthMipmap, float4(uv, 0, _MaxLOD));
			if (_ViewMode == 5) return float4(tex2D(_CameraGBufferTexture0, uv).xyz, 1);
			if (_ViewMode == 6) return float4(tex2D(_CameraGBufferTexture1, uv).xyz, 1);
			if (_ViewMode == 7) return float4(1, 1, 1, 1) * tex2D(_CameraGBufferTexture0, uv).w;
			if (_ViewMode == 8) return float4(1, 1, 1, 1) * tex2D(_CameraGBufferTexture1, uv).w;
			if (_ViewMode == 9) return float4(tex2D(_CameraGBufferTexture3, uv).xyz, 1);

			return (col * (1 - smooth) + refcol * smooth) * _ReflectionRate + col * (1 - _ReflectionRate);
		}

		float4 xblur(v2f i) : SV_Target
		{
			float2 uv = i.screen.xy / i.screen.w;
			float2 size = _ReflectionTexture_TexelSize;
			float smooth = tex2D(_CameraGBufferTexture1, uv).w;

            // compare depth
            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
            float depthR = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv + float2(1, 0) * size);
            float depthL = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv - float2(1, 0) * size);
            if (depth <= 0) return tex2D(_ReflectionTexture, uv);

            float weight[5] = { 0.22702703, 0.19459459, 0.12162162, 0.05405405, 0.01621622 };
            float offset[5] = { 0.0, 1.0, 2.0, 3.0, 4.0 };

            float4 originalColor = tex2D(_ReflectionTexture, uv);
            float4 blurredColor = tex2D(_ReflectionTexture, uv) * weight[0];

            for (int j = 1; j < 5; ++j)
            {
                blurredColor += tex2D(_ReflectionTexture, uv + float2(offset[j], 0) * size) * weight[j];
                blurredColor += tex2D(_ReflectionTexture, uv - float2(offset[j], 0) * size) * weight[j];
            }

			float4 o = (abs(depthR - depthL) > _BlurThreshold) ? originalColor : blurredColor * smooth + originalColor * (1 - smooth);
			return o;
		}

		float4 yblur(v2f i) : SV_Target
		{
			float2 uv = i.screen.xy / i.screen.w;
			float2 size = _ReflectionTexture_TexelSize;
			float smooth = tex2D(_CameraGBufferTexture1, uv).w;

            // compare depth
            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
            float depthT = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv + float2(0, 1) * size);
            float depthB = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv - float2(0, 1) * size);
            if (depth <= 0) return tex2D(_ReflectionTexture, uv);

            float weight[5] = { 0.22702703, 0.19459459, 0.12162162, 0.05405405, 0.01621622 };
            float offset[5] = { 0.0, 1.0, 2.0, 3.0, 4.0 };

            float4 originalColor = tex2D(_ReflectionTexture, uv);
            float4 blurredColor = tex2D(_ReflectionTexture, uv) * weight[0];
            for (int j = 1; j < 5; ++j)
            {
                blurredColor += tex2D(_ReflectionTexture, uv + float2(0, offset[j]) * size) * weight[j];
                blurredColor += tex2D(_ReflectionTexture, uv - float2(0, offset[j]) * size) * weight[j];
            }

			float4 o = (abs(depthT - depthB) > _BlurThreshold) ? originalColor : blurredColor * smooth + originalColor * (1 - smooth);
			return o;
		}

		float4 accumulation(v2f i) : SV_Target
		{
			float2 uv = i.screen.xy / i.screen.w;
			float4 base = tex2D(_PreAccumulationTexture, uv);
			float4 reflection = tex2D(_ReflectionTexture, uv);
			float blend = 0.2;
			return lerp(base, reflection, blend);
		}

		float4 composition(v2f i) : SV_Target
		{
			float2 uv = i.screen.xy / i.screen.w;
			float4 base = tex2D(_MainTex, uv);
			float4 reflection = tex2D(_AccumulationTexture, uv);
			float a = reflection.a;
			return lerp(base, reflection, a);
		}

		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment outDepthTexture
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment reflection
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_fullscreen
			#pragma fragment xblur
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_fullscreen
			#pragma fragment yblur
			ENDCG
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_fullscreen
			#pragma fragment accumulation
			ENDCG
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment composition
			ENDCG
		}
	}
}
