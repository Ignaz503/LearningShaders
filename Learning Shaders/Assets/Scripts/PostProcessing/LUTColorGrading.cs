using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LUTColorGrading : MonoBehaviour
{
    [SerializeField] Texture2D lut = null;
    [SerializeField] [Range(0, 1)] float contribution = 1f;

    Material mat;

    // Start is called before the first frame update
    void Start()
    {
        if (lut == null)
            return;

        mat = new Material(Shader.Find("Hidden/LUTColorGrading"));

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetTexture("_LUT", lut);
        mat.SetFloat("_Contribution", contribution);
        Graphics.Blit(source, destination, mat);
    }

}
