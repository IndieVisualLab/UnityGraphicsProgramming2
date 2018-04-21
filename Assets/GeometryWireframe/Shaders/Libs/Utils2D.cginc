#ifndef UTILS2D_INCLUDED
#define UTILS2D_INCLUDED

float hash11(float p) {
	float2 p2 = frac(p * float2(443.8975, 397.2973));
	p2 += dot(p2.xy, p2.yx + 19.19);
	return frac(p2.x * p2.y);
}

float hash13(float3 p) {
	p = frac(p * float3(443.8975, 397.2973, 491.1871));
	p += dot(p.xyz, p.yzx + 19.19);
	return frac(p.x * p.y * p.z);
}

float2 hash21(float p) {
	float3 p3 = frac(p * float3(443.8975, 397.2973, 491.1871));
	p3 += dot(p3.xyz, p3.yzx + 19.19);
	return frac(float2(p3.x * p3.y, p3.z * p3.x));
}

float random(in float x) {
	return frac(sin(x)*1e4);
}

float random(float2 _st) {
	return frac(sin(dot(_st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

float random(float3 _st) {
	return frac(sin(dot(_st.xyz, float3(12.9898, 78.233, 56.787))) * 43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise(float2 _st) {
	float2 i = floor(_st);
	float2 f = frac(_st);

	// Four corners in 2D of a tile
	float a = random(i);
	float b = random(i + float2(1.0, 0.0));
	float c = random(i + float2(0.0, 1.0));
	float d = random(i + float2(1.0, 1.0));

	float2 u = f * f * (3.0 - 2.0 * f);

	return lerp(a, b, u.x) +
		(c - a)* u.y * (1.0 - u.x) +
		(d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm(float2 _st) {
	float v = 0.0;
	float a = 0.5;
	float2 shift = float2(10.0, 10.0);
	// Rotate to reduce axial bias
	float2x2  rot = float2x2 (cos(0.5), sin(0.5),
		-sin(0.5), cos(0.50));
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(_st);
		_st = mul(rot, _st * 2.0) + shift;
		a *= 0.5;
	}
	return v;
}

float2 brickTile(float2 uv, float zoom) {
	uv *= zoom;
	uv.x += step(1.0, fmod(uv.y, 2.0)) * 0.5;
	return frac(uv);
}

#endif