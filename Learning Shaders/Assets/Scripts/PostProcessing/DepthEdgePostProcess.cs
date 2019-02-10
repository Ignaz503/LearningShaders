using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class DepthEdgePostProcess : MonoBehaviour
{
    Material mat;
    [SerializeField][Range(0, 1)] float threshold = 0.01f;
    [SerializeField] Color edgeColor = Color.black;

    private void Awake()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    // Start is called before the first frame update
    void Start()
    {
        mat = new Material(Shader.Find("Hidden/DepthEdge"));
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("_Threshold", threshold);
        mat.SetColor("_EdgeColor", edgeColor);

        Graphics.Blit(source, destination, mat);
    }

}
