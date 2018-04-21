#ifndef TRANSFORM_INCLUDED
#define TRANSFORM_INCLUDED
// calculating formula from
// http://www.cg.info.hiroshima-cu.ac.jp/~miyazaki/knowledge/tech07.html

float3 rotateX(float3 v, float angle) {
	float
		s = sin(angle),
		c = cos(angle);
	float4x4 rot = float4x4(
		1, 0, 0, 0,
		0, c, -s, 0,
		0, s, c, 0,
		0, 0, 0, 1
		);
	return mul(rot, float4(v, 1)).xyz;
}
float3 rotateX(float3 v, float angle, float3 center) {
	v -= center;
	v = rotateX(v, angle);
	v += center;
	return v;
}

float3 rotateY(float3 v, float angle) {
	float
		s = sin(angle),
		c = cos(angle);
	float4x4 rot = float4x4(
		c, 0, s, 0,
		0, 1, 0, 0,
		-s, 0, c, 0,
		0, 0, 0, 1
		);
	return mul(rot, float4(v, 1)).xyz;
}
float3 rotateY(float3 v, float angle, float3 center) {
	v -= center;
	v = rotateY(v, angle);
	v += center;
	return v;
}

float3 rotateZ(float3 v, float angle) {
	float
		s = sin(angle),
		c = cos(angle);
	float4x4 rot = float4x4(
		c, -s, 0, 0,
		s, c, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
		);
	return mul(rot, float4(v, 1)).xyz;
}
float3 rotateZ(float3 v, float angle, float3 center) {
	v -= center;
	v = rotateZ(v, angle);
	v += center;
	return v;
}

float3 rotate(float3 v, float3 axis, float angle) {
	float
		s = sin(angle),
		c = cos(angle);
	float
		nx = axis.x,
		ny = axis.y,
		nz = axis.z;
	float4x4 rot = float4x4(
		nx*nx*(1 - c) + c, nx*ny*(1 - c) - nz * s, nz*nx*(1 - c) + ny * s, 0,
		nx*ny*(1 - c) + nz * s, ny*ny*(1 - c) + c, ny*nz*(1 - c) - nx * s, 0,
		nz*nx*(1 - c) - ny * s, ny*nz*(1 - c) + nx * s, nz*nz*(1 - c) + c, 0,
		0, 0, 0, 1
		);
	return mul(rot, float4(v, 1)).xyz;
}
float3 rotate(float3 v, float3 axis, float angle, float3 center) {
	v -= center;
	v = rotate(v, axis, angle);
	v += center;
	return v;
}
#endif // TRANSFORM_INCLUDED