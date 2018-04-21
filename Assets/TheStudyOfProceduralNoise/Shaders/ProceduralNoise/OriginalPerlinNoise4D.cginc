#ifndef ORIGINAL_PERLIN_NOISE_4D
#define ORIGINAL_PERLIN_NOISE_4D

// 疑似乱数生成
float4 pseudoRandom(float4 v)
{
	v = float4(
		dot(v, float4(127.1, 311.7, 542.3, 215.1)),
		dot(v, float4(269.5, 183.3, 461.7, 523.3)),
		dot(v, float4(732.1, 845.3, 231.7, 641.1)),
		dot(v, float4(321.3, 195.7, 591.5, 104.3)));
	return -1.0 + 2.0 * frac(sin(v) * 43758.5453123);
}

// 補間関数（3次エルミート曲線）= smoothstep
float4 interpolate(float4 t)
{
	return t*t*(3.0 - 2.0*t);
}

// Original Perlin Noise 4D
float originalPerlinNoise(float4 v)
{
	// 格子の整数部の座標
	float4 i = floor(v);
	// 格子の小数部の座標
	float4 f = frac(v);

	// 格子の16つの角の座標値
	float4 i0000 = i;
	float4 i1000 = i + float4(1.0, 0.0, 0.0, 0.0);
	float4 i0100 = i + float4(0.0, 1.0, 0.0, 0.0);
	float4 i1100 = i + float4(1.0, 1.0, 0.0, 0.0);
	float4 i0010 = i + float4(0.0, 0.0, 1.0, 0.0);
	float4 i1010 = i + float4(1.0, 0.0, 1.0, 0.0);
	float4 i0110 = i + float4(0.0, 1.0, 1.0, 0.0);
	float4 i1110 = i + float4(1.0, 1.0, 1.0, 0.0);
	float4 i0001 = i + float4(0.0, 0.0, 0.0, 1.0);
	float4 i1001 = i + float4(1.0, 0.0, 0.0, 1.0);
	float4 i0101 = i + float4(0.0, 1.0, 0.0, 1.0);
	float4 i1101 = i + float4(1.0, 1.0, 0.0, 1.0);
	float4 i0011 = i + float4(0.0, 0.0, 1.0, 1.0);
	float4 i1011 = i + float4(1.0, 0.0, 1.0, 1.0);
	float4 i0111 = i + float4(0.0, 1.0, 1.0, 1.0);
	float4 i1111 = i + float4(1.0, 1.0, 1.0, 1.0);

	// それぞれの格子点から点Pへのベクトル
	float4 p0000 = f;
	float4 p1000 = f - float4(1.0, 0.0, 0.0, 0.0);
	float4 p0100 = f - float4(0.0, 1.0, 0.0, 0.0);
	float4 p1100 = f - float4(1.0, 1.0, 0.0, 0.0);
	float4 p0010 = f - float4(0.0, 0.0, 1.0, 0.0);
	float4 p1010 = f - float4(1.0, 0.0, 1.0, 0.0);
	float4 p0110 = f - float4(0.0, 1.0, 1.0, 0.0);
	float4 p1110 = f - float4(1.0, 1.0, 1.0, 0.0);
	float4 p0001 = f - float4(0.0, 0.0, 0.0, 1.0);
	float4 p1001 = f - float4(1.0, 0.0, 0.0, 1.0);
	float4 p0101 = f - float4(0.0, 1.0, 0.0, 1.0);
	float4 p1101 = f - float4(1.0, 1.0, 0.0, 1.0);
	float4 p0011 = f - float4(0.0, 0.0, 1.0, 1.0);
	float4 p1011 = f - float4(1.0, 0.0, 1.0, 1.0);
	float4 p0111 = f - float4(0.0, 1.0, 1.0, 1.0);
	float4 p1111 = f - float4(1.0, 1.0, 1.0, 1.0);

	// 格子点それぞれの勾配
	float4 g0000 = pseudoRandom(i0000);
	float4 g1000 = pseudoRandom(i1000);
	float4 g0100 = pseudoRandom(i0100);
	float4 g1100 = pseudoRandom(i1100);
	float4 g0010 = pseudoRandom(i0010);
	float4 g1010 = pseudoRandom(i1010);
	float4 g0110 = pseudoRandom(i0110);
	float4 g1110 = pseudoRandom(i1110);
	float4 g0001 = pseudoRandom(i0001);
	float4 g1001 = pseudoRandom(i1001);
	float4 g0101 = pseudoRandom(i0101);
	float4 g1101 = pseudoRandom(i1101);
	float4 g0011 = pseudoRandom(i0011);
	float4 g1011 = pseudoRandom(i1011);
	float4 g0111 = pseudoRandom(i0111);
	float4 g1111 = pseudoRandom(i1111);

	// 正規化
	g0000 = normalize(g0000);
	g1000 = normalize(g1000);
	g0100 = normalize(g0100);
	g1100 = normalize(g1100);
	g0010 = normalize(g0010);
	g1010 = normalize(g1010);
	g0110 = normalize(g0110);
	g1110 = normalize(g1110);
	g0001 = normalize(g0001);
	g1001 = normalize(g1001);
	g0101 = normalize(g0101);
	g1101 = normalize(g1101);
	g0011 = normalize(g0011);
	g1011 = normalize(g1011);
	g0111 = normalize(g0111);
	g1111 = normalize(g1111);

	// 各格子点のノイズの値を計算
	float n0000 = dot(g0000, p0000);
	float n1000 = dot(g1000, p1000);
	float n0100 = dot(g0100, p0100);
	float n1100 = dot(g1100, p1100);
	float n0010 = dot(g0010, p0010);
	float n1010 = dot(g1010, p1010);
	float n0110 = dot(g0110, p0110);
	float n1110 = dot(g1110, p1110);
	float n0001 = dot(g0001, p0001);
	float n1001 = dot(g1001, p1001);
	float n0101 = dot(g0101, p0101);
	float n1101 = dot(g1101, p1101);
	float n0011 = dot(g0011, p0011);
	float n1011 = dot(g1011, p1011);
	float n0111 = dot(g0111, p0111);
	float n1111 = dot(g1111, p1111);

	// 補間係数を求める
	float4 u_xyzw = interpolate(f);
	// 補間
	float4 n_0w = lerp(float4(n0000, n1000, n0100, n1100), float4(n0001, n1001, n0101, n1101), u_xyzw.w);
	float4 n_1w = lerp(float4(n0010, n1010, n0110, n1110), float4(n0011, n1011, n0111, n1111), u_xyzw.w);
	float4 n_zw = lerp(n_0w, n_1w, u_xyzw.z);
	float2 n_yzw = lerp(n_zw.xy, n_zw.zw, u_xyzw.y);
	float  n_xyzw = lerp(n_yzw.x, n_yzw.y, u_xyzw.x);

	return n_xyzw;
}
#endif

