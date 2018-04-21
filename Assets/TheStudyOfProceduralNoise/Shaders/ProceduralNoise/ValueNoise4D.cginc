#ifndef VALUE_NOISE_4D
#define VALUE_NOISE_4D

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

// 4次元 Value Noise
float valueNoise(float4 x)
{
	// 整数部
	float4 i = floor(x);
	// 小数部
	float4 f = frac(x);

	// 格子点の座標値
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

	// 格子点の座標上での疑似乱数の値
	float n0000 = pseudoRandom(i0000);
	float n1000 = pseudoRandom(i1000);
	float n0100 = pseudoRandom(i0100);
	float n1100 = pseudoRandom(i1100);
	float n0010 = pseudoRandom(i0010);
	float n1010 = pseudoRandom(i1010);
	float n0110 = pseudoRandom(i0110);
	float n1110 = pseudoRandom(i1110);
	float n0001 = pseudoRandom(i0001);
	float n1001 = pseudoRandom(i1001);
	float n0101 = pseudoRandom(i0101);
	float n1101 = pseudoRandom(i1101);
	float n0011 = pseudoRandom(i0011);
	float n1011 = pseudoRandom(i1011);
	float n0111 = pseudoRandom(i0111);
	float n1111 = pseudoRandom(i1111);

	// 補間係数を求める
	float4 u = interpolate(f);
	// 4次元格子の補間	
	float4 n_0w   = lerp(float4(n0000, n1000, n0100, n1100), float4(n0001, n1001, n0101, n1101), u.w);
	float4 n_1w   = lerp(float4(n0010, n1010, n0110, n1110), float4(n0011, n1011, n0111, n1111), u.w);
	float4 n_zw   = lerp(n_0w, n_1w, u.z);
	float2 n_yzw  = lerp(n_zw.xy, n_zw.zw, u.y);
	float  n_xyzw = lerp(n_yzw.x, n_yzw.y, u.x);

	return n_xyzw;
}

#endif

