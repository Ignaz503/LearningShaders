using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EditorStyleCamera : MonoBehaviour {


    public float lookSpeedH = 2f;
    public float lookSpeedV = 2f;
    public float zoomSpeed = 3f;
    public float dragSpeed = 10f;

    private float yaw = 0f;
    private float pitch = 0f;

    private void Start()
    {
        yaw = transform.eulerAngles.y;
        pitch = transform.eulerAngles.x;
    }

    void Update()
    {
        //Look 
        if (Input.GetMouseButton(1))
        {
            yaw += lookSpeedH * Input.GetAxisRaw("Mouse X");
            pitch -= lookSpeedV * Input.GetAxisRaw("Mouse Y");

            transform.eulerAngles = new Vector3(pitch, yaw, 0f);
        }

        //drag 
        if (Input.GetMouseButton(2))
        {
            transform.Translate(-Input.GetAxisRaw("Mouse X") * Time.unscaledDeltaTime * dragSpeed, -Input.GetAxisRaw("Mouse Y") * Time.unscaledDeltaTime * dragSpeed, 0);
        }

        //Zoom 
        transform.Translate(0, 0, Input.GetAxis("Mouse ScrollWheel") * zoomSpeed, Space.Self);
    }
}

