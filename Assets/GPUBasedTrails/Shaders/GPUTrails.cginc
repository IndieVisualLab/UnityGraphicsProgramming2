#ifndef GPUTRAILS_INCLUDED
#define GPUTRAILS_INCLUDED

struct Input
{
    float3 position;
};

struct Trail
{
	int currentNodeIdx;
};

struct Node
{
	float time;
    float3 position;
};


uint _NodeNumPerTrail;

int ToNodeBufIdx(int trailIdx, int nodeIdx)
{
	nodeIdx %= _NodeNumPerTrail;
	return trailIdx * _NodeNumPerTrail + nodeIdx;
}

bool IsValid(Node node)
{
	return node.time >= 0;
}

#endif