#ifndef ORIGINAL_PERLIN_NOISE_3D
#define ORIGINAL_PERLIN_NOISE_3D

// 疑似乱数生成
float3 pseudoRandom(float3 v)
{
	v = float3(dot(v, float3(127.1, 311.7, 542.3)), dot(v, float3(269.5, 183.3, 461.7)), dot(v, float3(732.1, 845.3, 231.7)));
	return -1.0 + 2.0 * frac(sin(v) * 43758.5453123);
}

// 補間関数（3次エルミート曲線）= smoothstep
float3 interpolate(float3 t)
{
	return t*t*(3.0 - 2.0*t);
}

// Original Perlin Noise 3D
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

	// それぞれの格子点から点Pへのベクトル
	float3 p000 = f;
	float3 p100 = f - float3(1.0, 0.0, 0.0);
	float3 p010 = f - float3(0.0, 1.0, 0.0);
	float3 p110 = f - float3(1.0, 1.0, 0.0);
	float3 p001 = f - float3(0.0, 0.0, 1.0);
	float3 p101 = f - float3(1.0, 0.0, 1.0);
	float3 p011 = f - float3(0.0, 1.0, 1.0);
	float3 p111 = f - float3(1.0, 1.0, 1.0);

	// 格子点それぞれの勾配
	float3 g000 = pseudoRandom(i000);
	float3 g100 = pseudoRandom(i100);
	float3 g010 = pseudoRandom(i010);
	float3 g110 = pseudoRandom(i110);
	float3 g001 = pseudoRandom(i001);
	float3 g101 = pseudoRandom(i101);
	float3 g011 = pseudoRandom(i011);
	float3 g111 = pseudoRandom(i111);

	// 正規化
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
	float4 n_z   = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), u_xyz.z);
	float2 n_yz  = lerp(n_z.xy, n_z.zw, u_xyz.y);
	float  n_xyz = lerp(n_yz.x, n_yz.y, u_xyz.x);
	return n_xyz;
}
#endif

