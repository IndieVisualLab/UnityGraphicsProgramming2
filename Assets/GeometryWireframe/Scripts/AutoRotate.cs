using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRotate : MonoBehaviour {

    public Vector3 axis = Vector3.up;
    public float speed = 1;
	
	// Update is called once per frame
	void Update () {
        transform.Rotate(axis, speed * Time.deltaTime);	
	}
}
