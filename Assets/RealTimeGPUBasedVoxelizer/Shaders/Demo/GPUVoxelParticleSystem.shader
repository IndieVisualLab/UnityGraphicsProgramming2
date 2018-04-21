Shader "Voxelizer/Demo/GPUVoxelParticleSystem" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_Scale ("Scale", Range(0.0, 1.0)) = 0.95
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM

		#pragma target 3.0
		#pragma surface surf Standard vertex:vert addshadow 
		#pragma multi_compile_instancing
		#pragma instancing_options procedural:setup

		#include "UnityCG.cginc"
		#include "./Quaternion.cginc"
		#include "./Matrix.cginc"
		#include "./VoxelParticle.cginc"

		struct Input {
			float4 color;
		};

		half _Glossiness;
		half _Metallic;
		float4 _Color;
		float4x4 _LocalToWorld, _WorldToLocal;
		float _Scale;

		#ifdef SHADER_API_D3D11
		StructuredBuffer<VoxelParticle> _ParticleBuffer;
		#endif

		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

		void setup()
		{
			unity_ObjectToWorld = _LocalToWorld;
			unity_WorldToObject = _WorldToLocal;
		}

		void vert (inout appdata_full v, out Input data) {
			UNITY_INITIALIZE_OUTPUT(Input, data);
			data.color = _Color;

			#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
			uint id = unity_InstanceID;
			#ifdef SHADER_API_D3D11
			VoxelParticle particle = _ParticleBuffer[id];
			float4x4 m = compose(particle.position.xyz, particle.rotation.xyzw, particle.scale.xyz * _Scale);
			v.vertex.xyz = mul(m, v.vertex.xyzw).xyz;
			v.normal.xyz = normalize(mul(m, float4(v.normal.xyz, 0)).xyz);
			#endif
			#endif
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = IN.color;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
