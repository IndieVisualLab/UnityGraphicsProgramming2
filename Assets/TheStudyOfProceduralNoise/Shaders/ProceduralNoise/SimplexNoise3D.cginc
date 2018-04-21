#ifndef SIMPLEX_NOISE_3D
#define SIMPLEX_NOISE_3D

// https://github.com/stegu/webgl-noise/blob/master/src/noise3D.glsl
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 

// 289の剰余を求める
float3 mod289(float3 x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// 289の剰余を求める
float4 mod289(float4 x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// 0～288の値を重複なく並べ換える
float4 permute(float4 x)
{
	return mod289(((x * 34.0) + 1.0) * x);
}

// 0～288の値を重複なく並べ換える
float3 permute(float3 x)
{
	return fmod(((x * 34.0) + 1.0) * x, 289.0);
}

// rは0.7近辺の値として 1.0/sqrt(r) のテイラー展開による近似
float4 taylorInvSqrt(float4 r)
{
	return 1.79284291400159 - 0.85373472095314 * r;
}

// Simplex Noise 3D
float simplexNoise(float3 v)
{
	// 定数
	const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
	const float4 D = float4(0.0, 0.5, 1.0, 2.0);

	float3 i  = floor(v + dot(v, C.yyy)); // 変形した座標の整数部
	float3 x0 = v   - i + dot(i, C.xxx);  // 単体1つめの頂点 
	
	float3 g = step(x0.yzx, x0.xyz);	  // 成分比較
	float3 l = 1.0 - g;
	float3 i1 = min(g.xyz, l.zxy);
	float3 i2 = max(g.xyz, l.zxy);

	//     x0 = x0 - 0. + 0.0 * C       // 単体1つめの頂点 
	float3 x1 = x0 - i1 + 1.0 * C.xxx;	// 単体2つめの頂点 
	float3 x2 = x0 - i2 + 2.0 * C.xxx;	// 単体3つめの頂点 
	float3 x3 = x0 - 1. + 3.0 * C.xxx;	// 単体4つめの頂点 

	// 勾配ベクトル計算時のインデックスを並べ替え
	i = mod289(i);
	float4 p = permute(permute(permute(
		  i.z + float4(0.0, i1.z, i2.z, 1.0))
		+ i.y + float4(0.0, i1.y, i2.y, 1.0))
		+ i.x + float4(0.0, i1.x, i2.x, 1.0));

	// 勾配ベクトルを計算
	float  n_ = 0.142857142857; // 1.0 / 7.0
	float3 ns = n_ * D.wyz - D.xzx;

	float4 j = p - 49.0 * floor(p * ns.z * ns.z);	// fmod(p, 7*7)

	float4 x_ = floor(j * ns.z);
	float4 y_ = floor(j - 7.0 * x_); // fmod(j, N)

	float4 x = x_ * ns.x + ns.yyyy;
	float4 y = y_ * ns.x + ns.yyyy;
	float4 h = 1.0 - abs(x) - abs(y);

	float4 b0 = float4(x.xy, y.xy);
	float4 b1 = float4(x.zw, y.zw);

	float4 s0 = floor(b0) * 2.0 + 1.0;
	float4 s1 = floor(b1) * 2.0 + 1.0;
	float4 sh = -step(h, float4(0.0, 0.0, 0.0, 0.0));

	float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
	float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

	float3 p0 = float3(a0.xy, h.x);
	float3 p1 = float3(a0.zw, h.y);
	float3 p2 = float3(a1.xy, h.z);
	float3 p3 = float3(a1.zw, h.w);

	// 勾配を正規化
	float4 norm = taylorInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// 放射円状ブレンドカーネル（放射円状に減衰）
	float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
	m = m * m;
	// 最終的なノイズの値を算出
	return 42.0 * dot(m * m, float4(dot(p0, x0), dot(p1, x1),
		dot(p2, x2), dot(p3, x3)));
}

#endif

