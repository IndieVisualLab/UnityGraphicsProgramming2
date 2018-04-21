#ifndef QUATERNION_INCLUDED
#define QUATERNION_INCLUDED

#define PI  3.14159265359
#define PI2 6.28318530718
// Quaternion multiplication.
// http://mathworld.wolfram.com/Quaternion.html
float4 qmul(float4 q1, float4 q2)
{
	return float4(
		q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz),
		q1.w * q2.w - dot(q1.xyz, q2.xyz)
		);
}

// Rotate a vector with a rotation quaternion.
// http://mathworld.wolfram.com/Quaternion.html
float3 rotateWithQuaternion(float3 v, float4 r)
{
	float4 r_c = r * float4(-1, -1, -1, 1);
	return qmul(r, qmul(float4(v, 0), r_c)).xyz;
}

float4 getAngleAxisRotation(float3 v, float3 axis, float angle) {
	axis = normalize(axis);
	float s, c;
	sincos(angle, s, c);
	return float4(axis.x*s, axis.y*s, axis.z*s, c);
}

float3 rotateAngleAxis(float3 v, float3 axis, float angle) {
	float4 q = getAngleAxisRotation(v, axis, angle);
	return rotateWithQuaternion(v, q);
}

float4 fromToRotation(float3 from, float3 to) {
	float3
		v1 = normalize(from),
		v2 = normalize(to),
		cr = cross(v1, v2);
	float4 q = float4(cr, 1 + dot(v1, v2));
	return normalize(q);
}

float4 eulerToQuaternion(float3 axis, float angle) {
	return float4 (
		axis.x * sin(angle * 0.5),
		axis.y * sin(angle * 0.5),
		axis.z * sin(angle * 0.5),
		cos(angle * 0.5)
		);
}

float4 qlerp(float4 a, float4 b, float t)
{
	float4 r;
	float t_ = 1 - t;
	r.x = t_ * a.x + t * b.x;
	r.y = t_ * a.y + t * b.y;
	r.z = t_ * a.z + t * b.z;
	r.w = t_ * a.w + t * b.w;
	normalize(r);
	return r;
}

float4 qslerp(float4 a, float4 b, float t)
{
	float4 r;
	float t_ = 1 - t;
	float wa, wb;
	float theta = acos(a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w);
	float sn = sin(theta);
	wa = sin(t_ * theta) / sn;
	wb = sin(t * theta) / sn;
	r.x = wa * a.x + wb * b.x;
	r.y = wa * a.y + wb * b.y;
	r.z = wa * a.z + wb * b.z;
	r.w = wa * a.w + wb * b.w;
	normalize(r);
	return r;
}
#endif