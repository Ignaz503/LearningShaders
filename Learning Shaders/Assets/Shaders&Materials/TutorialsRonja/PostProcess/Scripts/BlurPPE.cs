using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class BlurPPE : MonoBehaviour
{
    [SerializeField] Material mat = null;

    private void Start()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        var tempTex = RenderTexture.GetTemporary(source.width, source.height);
        Graphics.Blit(source, tempTex, mat,0);
        Graphics.Blit(tempTex, destination, mat,1);
        RenderTexture.ReleaseTemporary(tempTex);
    }
}
