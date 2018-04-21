Shader "Hidden/SpotDrawer"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_DrawerPos ("drawer position", Vector) = (0,0,0,0)
		_Color ("drawer color", Color) = (1,1,1,1)
		_Emission ("emission", Float) = 1

		_Cookie ("spot cookie", 2D) = "white" {}
		_DrawerDepth ("drawer depth texture", 2D) = "white" {}
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
				float3 normal: NORMAL;
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v.uv2.y = 1.0 - v.uv2.y;

				v2f o;
				o.vertex = float4(v.uv2*2.0 - 1.0, 0.0, 1.0);
				o.uv = v.uv2;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			sampler2D _MainTex;

			uniform float4x4 _ProjMatrix, _WorldToDrawerMatrix;

			sampler2D _Cookie, _DrawerDepth;
			half4 _DrawerPos, _Color;
			half _Emission;

			half4 frag (v2f i) : SV_Target
			{
				///diffuse
				half3 to = i.worldPos - _DrawerPos.xyz;
				half3 dir = normalize(to);
				half dist = length(to);
				half atten = _Emission * dot(-dir, i.normal) / (dist * dist);

				///spot cookie
				half4 drawerSpacePos = mul(_WorldToDrawerMatrix, half4(i.worldPos, 1.0));
				half4 projPos = mul(_ProjMatrix, drawerSpacePos);
				projPos.z *= -1;
				half2 drawerUv = projPos.xy / projPos.z;
				drawerUv = drawerUv * 0.5 + 0.5;
				half cookie = tex2D(_Cookie, drawerUv);
				cookie *= 0<drawerUv.x && drawerUv.x<1 && 0<drawerUv.y && drawerUv.y<1 && 0<projPos.z;

				///shadow
				half drawerDepth = tex2D(_DrawerDepth, drawerUv).r;
				atten *= 1.0 - saturate(10 * abs(drawerSpacePos.z) - 10 * drawerDepth);

				i.uv.y = 1 - i.uv.y;
				half4 col = tex2D(_MainTex, i.uv);
				col.rgb = lerp(col.rgb, _Color.rgb, saturate(col.a * _Emission * atten * cookie));
				col.a = 1;
				return col;
			}
			ENDCG
		}
	}
}
