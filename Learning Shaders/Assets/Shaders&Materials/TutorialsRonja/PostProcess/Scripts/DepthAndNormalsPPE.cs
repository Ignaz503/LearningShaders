using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class DepthAndNormalsPPE : MonoBehaviour
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
        Matrix4x4 viewToWorld = cam.cameraToWorldMatrix;
        mat.SetMatrix("_viewToWorld", viewToWorld);
        Graphics.Blit(source, destination, mat);
    }
}
