using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthNormalsWithoutViewToWorld : MonoBehaviour
{
    [SerializeField] Material mat = null;
    Camera cam;

    private void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, mat);
    }
}
