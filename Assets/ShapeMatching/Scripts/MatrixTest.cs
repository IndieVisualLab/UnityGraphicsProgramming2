using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatrixTest : MonoBehaviour {

    [SerializeField] private Matrix2x2 inputMatrix = new Matrix2x2(1, 2, 3, 4);

    void Start () {
        
        Debug.Log("--- Input Matrix\n" + inputMatrix);

        Matrix2x2 u = new Matrix2x2(),
                  s = new Matrix2x2(),
                  v = new Matrix2x2();
        inputMatrix.SVD(ref u, ref s, ref v);

        Debug.Log("--- U\n" + u);
        Debug.Log("--- S\n" + s);
        Debug.Log("--- V^t\n" + v.Transpose());

        Debug.Log("### Back ###");
        Debug.Log("--- A = USV^t\n" + u * s * v.Transpose());
        
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
