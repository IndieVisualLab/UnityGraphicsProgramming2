#ifndef SIMPLEX_NOISE_2D
#define SIMPLEX_NOISE_2D

// https://github.com/stegu/webgl-noise/blob/master/src/noise2D.glsl
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
float2 mod289(float2 x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

// 0～288の値を重複なく並べ換える
float3 permute(float3 x)
{
	return mod289(((x * 34.0) + 1.0) * x);
}

// rは0.7近辺の値として 1.0/sqrt(r) のテイラー展開による近似
float3 taylorInvSqrt(float3 r)
{
	return 1.79284291400159 - 0.85373472095314 * r;
}

// Simplex Noise 2D
float simplexNoise(float2 v)
{
	// 定数
	const float4 C = float4
	(
		0.211324865405187,   // (3.0-sqrt(3.0))/6.0
		0.366025403784439,   // 0.5*(sqrt(3.0)-1.0)
		-0.577350269189626,  // -1.0 + 2.0 * C.x
		0.024390243902439    // 1.0 / 41.0
	);

	float2 i  = floor(v + dot(v, C.yy)); // 変形した座標の整数部
	float2 x0 = v - i + dot(i, C.xx);    // 単体1つめの頂点 
	float2 x1 = x0.xy + C.xx;			 // 単体2つめの頂点
	float2 x2 = x0.xy + C.zz;			 // 単体3つめの頂点

	// 単体のユニットの原点（x0）からの相対的なx, y成分を比較し、
	// 2つめの頂点の座標がどちらであるか判定
	float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
	x1 -= i1;

	// 勾配ベクトル計算時のインデックスを並べ替え
	i = mod289(i); // 並べ換え時、オーバーフローが起きないように値を0～288に制限
	float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0))
		+ i.x + float3(0.0, i1.x, 1.0));

	// 放射状円ブレンドカーネル（放射円状に減衰）
	float3 m = max(0.5 - float3(dot(x0, x0), dot(x1.xy, x1.xy), dot(x2.xy, x2.xy)), 0.0);
	m = m * m;
	m = m * m;

	// 勾配を計算
	// 2次元正軸体（45°回転した四角形）の境界に均一に分散した41個の点
	// 41という数字は、ほどよく分散しかつ、41×7=287と289 に近い数値であるから
	float3 x  = 2.0 * frac(p * C.www) - 1.0; // -1.0～1.0の範囲で41個に分布したx軸の値
	float3 h  = abs(x) - 0.5;				 // 勾配のy成分
	float3 ox = floor(x + 0.5);				 // 四捨五入(=round())
	float3 a0 = x - ox;						 // 勾配のx成分

	// mをスケーリングすることで、間接的に勾配ベクトルを正規化
	m *= taylorInvSqrt(a0*a0 + h*h);

	// 点Pにおけるノイズの値を計算
	float3 g;
	g.x  = a0.x  * x0.x               + h.x  * x0.y;
	g.yz = a0.yz * float2(x1.x, x2.x) + h.yz * float2(x1.y, x2.y);

	// 値の範囲が[-1, 1]となるように、任意の因数でスケーリング
	return 130.0 * dot(m, g);
}

#endif

