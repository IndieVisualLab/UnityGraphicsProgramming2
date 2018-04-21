#ifndef __VPARTICLE_COMMON_INCLUDED__
#define __VPARTICLE_COMMON_INCLUDED__

struct VoxelParticle
{
    float3 position;
    float4 rotation;
    float3 scale;
    float3 velocity;
    float speed;
    float size;
    float lifetime;
};

#endif
