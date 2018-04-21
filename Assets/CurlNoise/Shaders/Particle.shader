Shader "Custom/Particle"
{
    Properties
    {
	    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    }
    CGINCLUDE
        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "AutoLight.cginc"

        struct Params
        {
            float3 emitPos;
            float3 position;
            float4 velocity; //xyz = velocity, w = velocity coef
            float3 life;     // x = time elapsed, y = life time, z = isActive 1 is active, -1 is disactive
            float3 size;     // x = current size, y = start size, z = target size.
            float4 color;
            float4 startColor;
            float4 endColor;
        };

		#if SHADER_TARGET >= 45
        StructuredBuffer<Params> buf;
		#endif

        sampler2D _MainTex;
        float4x4  modelMatrix;

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv_MainTex : TEXCOORD0;
            float3 ambient : TEXCOORD1;
            float3 diffuse : TEXCOORD2;
            float3 color : TEXCOORD3;
			SHADOW_COORDS(4)
        };

        v2f vert (appdata_full v, uint id : SV_InstanceID)
        {
            Params p = buf[id];

            float3 localPosition = v.vertex.xyz * p.size.x + p.position;
            float3 worldPosition = mul(modelMatrix, float4(localPosition, 1.0));
            float3 worldNormal = v.normal;

            float3 ndotl = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
            float3 ambient = ShadeSH9(float4(worldNormal, 1.0f));
            float3 diffuse = (ndotl * _LightColor0.rgb);
            float3 color = p.color;

            v2f o;
            o.pos = mul(UNITY_MATRIX_VP, float4(worldPosition, 1.0f));
            o.uv_MainTex = v.texcoord;
            o.ambient = ambient;
            o.diffuse = diffuse;
            o.color = color;
			TRANSFER_SHADOW(o)
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            //float2 uv = i.uv_MainTex * 2.0 - float2(1.0, 1.0);
            //float t = 0.1 / length(uv);
            //return float4(t,0,0,1);
            //return tex2D(_MainTex, i.uv_MainTex);
            fixed shadow = SHADOW_ATTENUATION(i);
            fixed4 albedo = tex2D(_MainTex, i.uv_MainTex);
            float3 lighting = i.diffuse * shadow + i.ambient;
            fixed4 output = fixed4(albedo.rgb * i.color * lighting, albedo.w);
            UNITY_APPLY_FOG(i.fogCoord, output);
            //fixed4 output = fixed4(albedo.rgb * i.color, albedo.w);
            return output;
        }
        ENDCG

	SubShader
	{
	    Tags {"LightMode"="ForwardBase"}
		Pass
		{
			CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
				#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
                #pragma target 5.0
			ENDCG
        }
	}
}