using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeometryOctahedronSphereInstancing : MonoBehaviour {
    
    struct OctahedronSphereData
    {
        public Vector3 position;
        public Quaternion rotation;
        public float scale;
        public int level;
    }

    const int THREAD_GROUP_X = 8;

    public int num = 1024;
    public float emitRange = 10f;
    public Material renderMaterial;

    public float noiseScale = 0.1f;
    public float noiseSpeed = 0.1f;

    public ComputeShader cs;

    ComputeBuffer _particleBuffer;
    int _particleNum = 0;

    
    // Use this for initialization
    void Start()
    {
        _particleNum = Mathf.CeilToInt((float)num / THREAD_GROUP_X) * THREAD_GROUP_X;
        Debug.Log("Particle Num " + _particleNum);

        _particleBuffer = new ComputeBuffer(_particleNum, System.Runtime.InteropServices.Marshal.SizeOf(typeof(OctahedronSphereData)));

        OctahedronSphereData[] octahedronSphereData = new OctahedronSphereData[_particleNum];
        for (int i = 0; i < _particleNum; i++)
        {
            octahedronSphereData[i].position = Random.insideUnitSphere * emitRange;
            octahedronSphereData[i].rotation = Random.rotation;
            octahedronSphereData[i].scale = Random.Range(0.1f, 0.5f);
            octahedronSphereData[i].level = 1;

        }
        _particleBuffer.SetData(octahedronSphereData);

        //// Init
        //cs.Dispatch(0, _particleNum / THREAD_GROUP_X, 1, 1);
    }

    // Update is called once per frame
    void Update()
    {
        cs.SetFloat("_Time", Time.time);
        cs.SetFloat("_NoiseScale", noiseScale);
        cs.SetFloat("_NoiseSpeed", noiseSpeed);
        cs.SetInt("_SubDivisionNum", 3);
        cs.SetBuffer(0, "_particleBuffer", _particleBuffer);
        cs.Dispatch(0, _particleNum / THREAD_GROUP_X, 1, 1);
    }

    void OnRenderObject()
    {
        //renderMaterial.SetFloat("_Time", Time.time);
        renderMaterial.SetFloat("_NoiseScale", noiseScale);
        renderMaterial.SetFloat("_NoiseSpeed", noiseSpeed);
        
        renderMaterial.SetBuffer("_particleBuffer", _particleBuffer);
        renderMaterial.SetPass(0);

        Graphics.DrawProcedural(MeshTopology.Points, _particleNum);
    }

    private void OnDestroy()
    {
        _particleBuffer.Release();
        _particleBuffer = null;
    }
}
