#ifndef color_h
#define color_h

float3 Hue(float hue)
{
	float3 rgb = frac(hue + float3(0.0, 2.0 / 3.0, 1.0 / 3.0));

	rgb = abs(rgb * 2.0 - 1.0);

	return clamp(rgb * 3.0 - 1.0, 0.0, 1.0);
}

float3 HSVtoRGB(float3 hsv)
{
	return ((Hue(hsv.x) - 1.0) * hsv.y + 1.0) * hsv.z;
}

float3 HsvToRgb(float3 c)
{
	float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

float3 hsv2rgb(float3 hsv)
{
	float3  rgb;
	int     Hi;
	float   f;
	float   p;
	float   q;
	float   t;

	Hi = fmod(floor(hsv.x / 60.0f), 6.0f);
	f = hsv.x / 60.0f - Hi;
	p = hsv.z * (1.0f - hsv.y);
	q = hsv.z * (1.0f - f * hsv.y);
	t = hsv.z * (1.0f - (1.0f - f) * hsv.y);

	if (Hi == 0) {
		rgb.x = hsv.z;
		rgb.y = t;
		rgb.z = p;
	}
	if (Hi == 1) {
		rgb.x = q;
		rgb.y = hsv.z;
		rgb.z = p;
	}
	if (Hi == 2) {
		rgb.x = p;
		rgb.y = hsv.z;
		rgb.z = t;
	}
	if (Hi == 3) {
		rgb.x = p;
		rgb.y = q;
		rgb.z = hsv.z;
	}
	if (Hi == 4) {
		rgb.x = t;
		rgb.y = p;
		rgb.z = hsv.z;
	}
	if (Hi == 5) {
		rgb.x = hsv.z;
		rgb.y = p;
		rgb.z = q;
	}

	return rgb;
}
#endif