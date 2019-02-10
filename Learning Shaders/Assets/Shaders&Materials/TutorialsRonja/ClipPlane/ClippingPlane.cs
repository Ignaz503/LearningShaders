using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClippingPlane : MonoBehaviour
{
    public Material mat;

    private void Update()
    {
        Plane p = new Plane(transform.up, transform.position);
        Vector4 planeRepresentation = new Vector4(p.normal.x, p.normal.y, p.normal.z, p.distance);

        mat.SetVector("_Plane", planeRepresentation);
    }
}
