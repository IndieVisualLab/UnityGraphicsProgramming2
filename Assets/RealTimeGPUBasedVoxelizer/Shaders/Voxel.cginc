#ifndef __VOXEL_COMMON_INCLUDED__
#define __VOXEL_COMMON_INCLUDED__

struct Voxel
{
    float3 position;
    bool fill;
    bool front;
};

bool is_front_voxel(Voxel v)
{
    return v.fill && v.front;
}

bool is_back_voxel(Voxel v)
{
    return v.fill && !v.front;
}

bool is_empty_voxel(Voxel v)
{
    return !v.fill;
}

#endif
