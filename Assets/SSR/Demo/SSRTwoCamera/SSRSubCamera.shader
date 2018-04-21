Shader "SSR/SSRSubCamera"
{
    Properties
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
	}
	SubShader
	{
		Blend Off
        ZTest Always
        ZWrite Off
        Cull Off

		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
	    sampler2D _CameraDepthTexture;

        struct v2f {
          float4 pos : SV_POSITION;
		  float4 screenPos: TEXCOORD1;
        };

        v2f vert (appdata_base v) {
          v2f o;
          o.pos = UnityObjectToClipPos(v.vertex);
		  o.screenPos = ComputeScreenPos(o.pos);
          return o;
        }

		half4 fragMain (v2f i) : SV_Target {
		  float2 uv = i.screenPos.xy / i.screenPos.w;
		  return tex2D(_MainTex, uv);
		}

        half4 fragDepth (v2f i) : SV_Target {
		  float2 uv = i.screenPos.xy / i.screenPos.w;
		  float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
		  return float4(d, d, d, 1.0);
        }

	    ENDCG

		Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragMain
            ENDCG
        }

		Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragDepth
            ENDCG
        }
	}
}
