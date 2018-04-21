#ifndef ORIGINAL_PERLIN_NOISE_2D
#define ORIGINAL_PERLIN_NOISE_2D

// 疑似乱数生成
float2 pseudoRandom(float2 v)
{
	v = float2(dot(v, float2(127.1, 311.7)), dot(v, float2(269.5, 183.3)));
	return -1.0 + 2.0 * frac(sin(v) * 43758.5453123);
}

// 補間関数（3次エルミート曲線）= smoothstep
float2 interpolate(float2 t)
{
	return t*t*(3.0 - 2.0*t);
}

// Original Perlin Noise 2D
float originalPerlinNoise(float2 v)
{
	// 格子の整数部の座標
	float2 i = floor(v);
	// 格子の小数部の座標
	float2 f = frac(v);

	// 格子の4つの角の座標値
	float2 i00 = i;
	float2 i10 = i + float2(1.0, 0.0);
	float2 i01 = i + float2(0.0, 1.0);
	float2 i11 = i + float2(1.0, 1.0);

	// それぞれの格子点から点Pへのベクトル
	float2 p00 = f;
	float2 p10 = f - float2(1.0, 0.0);
	float2 p01 = f - float2(0.0, 1.0);
	float2 p11 = f - float2(1.0, 1.0);

	// 格子点それぞれの勾配
	float2 g00 = pseudoRandom(i00);
	float2 g10 = pseudoRandom(i10);
	float2 g01 = pseudoRandom(i01);
	float2 g11 = pseudoRandom(i11);

	// 正規化
	g00 = normalize(g00);
	g10 = normalize(g10);
	g01 = normalize(g01);
	g11 = normalize(g11);

	// 各格子点のノイズの値を計算
	float n00 = dot(g00, p00);
	float n10 = dot(g10, p10);
	float n01 = dot(g01, p01);
	float n11 = dot(g11, p11);

	// 補間
	float2 u_xy = interpolate(f.xy);
	float2 n_x  = lerp(float2(n00, n01), float2(n10, n11), u_xy.x);
	float2 n_xy = lerp(n_x.x, n_x.y, u_xy.y);
	return n_xy;
}
#endif

