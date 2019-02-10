using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class SweapingWavePPE : MonoBehaviour
{
    Material mat;

    [SerializeField] float waveSpeed =10f;
    [SerializeField] bool waveActive = false;
    float waveDistance = 0f;

    private void Start()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
        mat = new Material(Shader.Find("Tutorial/PostProcess/SweepingWave"));
    }

    private void Update()
    {
        if (waveActive)
            waveDistance = waveDistance + waveSpeed * Time.deltaTime;
        else
            waveDistance = 0;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("_WaveDistance", waveDistance);
        Graphics.Blit(source, destination, mat);
    }

}
