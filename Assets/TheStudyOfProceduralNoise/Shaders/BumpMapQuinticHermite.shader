// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "TheStudyOfProceduralNoise/Bumped Diffuse/Quintic Hermite"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_NoiseFrequency("Noise Frequency", Float) = 1.0
		_NoiseSpeed("Noise Speed", Float) = 1.0
		_Epsilon("Epsilon", Float) = 0.1
		_BumpFactor("Bump Factor", Float) = 1.0
	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 300

		CGPROGRAM
		#pragma surface surf Lambert

		float _NoiseFrequency;
		float _NoiseSpeed;
		float _Epsilon;
		float _BumpFactor;

		// 疑似乱数生成
		float3 pseudoRandom(float3 v)
		{
			v = float3(dot(v, float3(127.1, 311.7, 542.3)), dot(v, float3(269.5, 183.3, 461.7)), dot(v, float3(732.1, 845.3, 231.7)));
			return -1.0 + 2.0 * frac(sin(v) * 43758.5453123);
		}

		// 補間関数（5次エルミート曲線）
		float3 interpolate(float3 f)
		{
			return f*f*f*(f*(f*6.0-15.0)+10.0);
		}

		// パーリンノイズ 3D
		float originalPerlinNoise(float3 v)
		{
			// 格子の整数部の座標
			float3 i = floor(v);
			// 格子の小数部の座標
			float3 f = frac(v);

			// 格子の8つの角の座標値
			float3 i000 = i;
			float3 i100 = i + float3(1.0, 0.0, 0.0);
			float3 i010 = i + float3(0.0, 1.0, 0.0);
			float3 i110 = i + float3(1.0, 1.0, 0.0);
			float3 i001 = i + float3(0.0, 0.0, 1.0);
			float3 i101 = i + float3(1.0, 0.0, 1.0);
			float3 i011 = i + float3(0.0, 1.0, 1.0);
			float3 i111 = i + float3(1.0, 1.0, 1.0);

			// 格子内部のそれぞれの格子点からのベクトル
			float3 p000 = f;
			float3 p100 = f - float3(1.0, 0.0, 0.0);
			float3 p010 = f - float3(0.0, 1.0, 0.0);
			float3 p110 = f - float3(1.0, 1.0, 0.0);
			float3 p001 = f - float3(0.0, 0.0, 1.0);
			float3 p101 = f - float3(1.0, 0.0, 1.0);
			float3 p011 = f - float3(0.0, 1.0, 1.0);
			float3 p111 = f - float3(1.0, 1.0, 1.0);

			// 格子点それぞれの勾配(3D)
			float3 g000 = pseudoRandom(i000);
			float3 g100 = pseudoRandom(i100);
			float3 g010 = pseudoRandom(i010);
			float3 g110 = pseudoRandom(i110);
			float3 g001 = pseudoRandom(i001);
			float3 g101 = pseudoRandom(i101);
			float3 g011 = pseudoRandom(i011);
			float3 g111 = pseudoRandom(i111);

			// 正規化（ベクトルの大きさを1にそろえる）
			g000 = normalize(g000);
			g100 = normalize(g100);
			g010 = normalize(g010);
			g110 = normalize(g110);
			g001 = normalize(g001);
			g101 = normalize(g101);
			g011 = normalize(g011);
			g111 = normalize(g111);

			// 各格子点のノイズの値を計算
			float n000 = dot(g000, p000);
			float n100 = dot(g100, p100);
			float n010 = dot(g010, p010);
			float n110 = dot(g110, p110);
			float n001 = dot(g001, p001);
			float n101 = dot(g101, p101);
			float n011 = dot(g011, p011);
			float n111 = dot(g111, p111);

			// 補間
			float3 u_xyz = interpolate(f);
			float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), u_xyz.z);
			float2 n_yz = lerp(n_z.xy, n_z.zw, u_xyz.y);
			float  n_xyz = lerp(n_yz.x, n_yz.y, u_xyz.x);
			return n_xyz;
		}

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _BumpMap;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha  = c.a;

			float2 uv = IN.uv_MainTex.xy * _NoiseFrequency;

			float2 eps = (float2)_Epsilon;

			float f  = originalPerlinNoise(float3(uv, _Time.y));
			float fx = originalPerlinNoise(float3(uv - eps * float2(1.0, 0.0), _Time.y));
			float fy = originalPerlinNoise(float3(uv - eps * float2(0.0, 1.0), _Time.y));

			fx = (fx - f) / eps.x;
			fy = (fy - f) / eps.y;

			// 法線
			float3 norm = float3(0.0, 0.0, 1.0);
			norm = normalize(norm + float3(fx, fy, 0.0) * _BumpFactor);

			o.Normal = norm;
		}
		ENDCG
	}
		FallBack "Legacy Shaders/Diffuse"
}
