Shader "Unlit/Simple/SpotLight-Reciever"
{
	Properties
	{
		_LitPos ("light position", Vector) = (0,0,0,0)
		_LitCol ("light color", Color) = (1,1,1,1)
		_Intensity ("light intensity", Float) = 1
		_Cookie ("spot cokie", 2D) = "white"{}
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

			sampler2D _Cookie;
			half4 _LitPos, _LitCol;
			half _Intensity;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half3 to = i.worldPos - _LitPos.xyz;
				half3 lightDir = normalize(to);
				half dist = length(to);
				half atten = _Intensity * dot(-lightDir, i.normal) / (dist * dist);

				half4 lightSpacePos = mul(_WorldToLitMatrix, half4(i.worldPos, 1.0));
				half4 projPos = mul(_ProjMatrix, lightSpacePos);
				projPos.z *= -1;
				half2 litUv = projPos.xy / projPos.z;
				litUv = litUv * 0.5 + 0.5;
				half lightCookie = tex2D(_Cookie, litUv);
				lightCookie *= 0<litUv.x && litUv.x<1 && 0<litUv.y && litUv.y<1 && 0<projPos.z;

				half4 col = max(0.0, atten) * _LitCol * lightCookie;
				return col;
			}
			ENDCG
		}
	}
}
