#ifndef VALUE_NOISE_2D
#define VALUE_NOISE_2D

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

// Value Noise 2D
float valueNoise(float2 x)
{
	// 整数部
	float2 i = floor(x);
	// 小数部
	float2 f = frac(x);

	// 格子点の座標値
	float2 i00 = i;
	float2 i10 = i + float2(1.0, 0.0);
	float2 i01 = i + float2(0.0, 1.0);
	float2 i11 = i + float2(1.0, 1.0);

	// 格子点の座標上での疑似乱数の値
	float n00 = pseudoRandom(i00);
	float n10 = pseudoRandom(i10);
	float n01 = pseudoRandom(i01);
	float n11 = pseudoRandom(i11);

	// 補間係数を求める
	float2 u = interpolate(f);
	// 2次元格子の補間
	return lerp(lerp(n00, n10, u.x), lerp(n01, n11, u.x), u.y);
}

#endif

