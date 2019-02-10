using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class ColorSetter : MonoBehaviour
{
    [SerializeField] Color color = Color.white;
    [SerializeField] bool random = true;
    // Start is called before the first frame update
    void Start()
    {
        MeshRenderer re = GetComponent<MeshRenderer>();

        if (random)
            re.material.color = Random.ColorHSV();
        else
            re.material.color = color;

    }
}
