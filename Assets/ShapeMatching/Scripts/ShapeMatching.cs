using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShapeMatching : MonoBehaviour {

    [SerializeField] private GameObject _destination;
    [SerializeField] private GameObject _target;
    [SerializeField] private GameObject _displayer;

    Vector2[] p, q;
    Vector2 centerP, centerQ;

    Matrix2x2 R;
    Vector2 t;
    
	void Start () {

        if (_destination.transform.childCount != _target.transform.childCount) return;

        int n = _destination.transform.childCount;
        Debug.Log("Number of points : " + n);

        // Set p, q
        p = new Vector2[n];
        q = new Vector2[n];
        centerP = Vector2.zero;
        centerQ = Vector2.zero;

        for(int i = 0; i < n; i++)
        {
            Vector2 pos = _destination.transform.GetChild(i).position;
            p[i] = pos;
            centerP += pos;

            pos = _target.transform.GetChild(i).position;
            q[i] = pos;
            centerQ += pos;
        }
        centerP /= n;
        centerQ /= n;




        // Calc p', q'
        Matrix2x2 H = new Matrix2x2(0, 0, 0, 0);
        for (int i = 0; i < n; i++)
        {
            p[i] = p[i] - centerP;
            q[i] = q[i] - centerQ;

            H += Matrix2x2.OuterProduct(q[i], p[i]);
        }

        Matrix2x2 u = new Matrix2x2();
        Matrix2x2 s = new Matrix2x2();
        Matrix2x2 v = new Matrix2x2();
        H.SVD(ref u, ref s, ref v);

        R = v * u.Transpose();
        Debug.Log(Mathf.Rad2Deg * Mathf.Acos(R.m00));
        t = centerP - R * centerQ;
        

        _displayer.transform.SetPositionAndRotation((Vector2)_displayer.transform.position + t, Quaternion.Euler(0, 0, Mathf.Rad2Deg * Mathf.Acos(R.m00)));
    }

	void Update () {

    }

    private void OnDrawGizmos()
    {

        if (!Application.isPlaying) return;

        for(int i = 0; i < _destination.transform.childCount; i++)
        {

            //Gizmos.DrawWireCube(resRotation * _target.transform.GetChild(i).position + resTranslate, new Vector3(1, 1, 1));
            //Gizmos.DrawWireCube(resRotation * _target.transform.GetChild(i).localPosition + (Vector2)_target.transform.position, new Vector3(1, 1, 1));

            Gizmos.color = Color.blue;
            Gizmos.DrawWireCube(R * (Vector2)_target.transform.GetChild(i).position + t, new Vector3(1, 1, 1));
        }
    }
}
