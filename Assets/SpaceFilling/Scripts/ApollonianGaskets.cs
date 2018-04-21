using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System;

using Random = UnityEngine.Random;

[Serializable]
public class ApollonianGaskets : MonoBehaviour {
    private List<Circle> circles = new List<Circle>();
    private List<SoddyCircles> soddys = new List<SoddyCircles>();
    

    private void Awake()
    {
        Circle c1, c2, c3;
        this.CreateFirstCircles(out c1, out c2, out c3);
        this.circles.Add(c1);
        this.circles.Add(c2);
        this.circles.Add(c3);

        this.soddys.Add(new SoddyCircles(c1, c2, c3));

        for(var i = 0; i < this.soddys.Count; i++)
        {
            var soddy = this.soddys[i];

            Circle c4, c5;
            soddy.GetApollonianGaskets(out c4, out c5);

            this.AddCircle(c4, soddy);
            this.AddCircle(c5, soddy);
        }

        this.soddys.Clear();
    }
    
    private void AddCircle(Circle c, SoddyCircles soddy)
    {
        if(c == null || c.Radius <= 0.01f)
        {
            return;
        }
        else if(c.Curvature < 0f)
        {
            this.circles.Add(c);
            this.soddys.AddRange(soddy.GetSoddyCircles(c));

            return;
        }

        for(var i = 0; i < this.circles.Count; i++)
        {
            var o = this.circles[i];
            
            if(o.Curvature < 0f)
            {
                continue;
            }
            else if(o.IsMatch(c, 0.01f) == true)
            {
                return;
            }
        }

        this.circles.Add(c);
        this.soddys.AddRange(soddy.GetSoddyCircles(c));
    }
    
    private void OnDrawGizmos()
    {
        if(this.circles.Count <= 0)
        {
            return;
        }

        Handles.color = Color.white;
        for(var i = 0; i < 3 && i < this.circles.Count; i++)
        {
            Handles.DrawWireDisc(this.Vec2ToVec3(this.circles[i].Position), Vector3.up, this.circles[i].Radius);
        }

        Handles.color = Color.red;
        for(var i = 3; i < this.circles.Count; i++)
        {
            Handles.DrawWireDisc(this.Vec2ToVec3(this.circles[i].Position), Vector3.up, this.circles[i].Radius);
        }
    }
    
    private void CreateFirstCircles(out Circle c1, out Circle c2, out Circle c3)
    {
        var r1 = Random.Range(1f, 5f);
        var r2 = Random.Range(1f, 5f);
        var r3 = Random.Range(1f, 5f);

        var p1 = this.GetRandPosInCircle(0f, 5f);
        c1 = new Circle(new Complex(p1), r1);

        var p2 = -p1.normalized * ((r1 - p1.magnitude) + r2);
        c2 = new Circle(new Complex(p2), r2);

        var p3 = this.GetThirdVertex(p1, p2, r1 + r2, r2 + r3, r1 + r3);
        c3 = new Circle(new Complex(p3), r3);
    }

    private Vector2 GetRandPosInCircle(float fieldMin, float fieldMax)
    {
        var theta = Random.Range(0f, Mathf.PI * 2f);
        var radius = Mathf.Sqrt(2f * Random.Range(0.5f * fieldMin * fieldMin, 0.5f * fieldMax * fieldMax));

        return new Vector2(radius * Mathf.Cos(theta), radius * Mathf.Sin(theta));
    }

    private Vector2 GetThirdVertex(Vector2 v1, Vector2 v2, float rab, float rbc, float rca)
    {
        var v21 = v2 - v1;

        var theta = Mathf.Acos((rab * rab + rca * rca - rbc * rbc) / (2f * rca * rab));
        theta += Mathf.Atan2(v21.y, v21.x);

        return v1 + new Vector2(
            rca * Mathf.Cos(theta),
            rca * Mathf.Sin(theta)
        );
    }

    private Vector3 Vec2ToVec3(Vector2 vec2)
    {
        return new Vector3(
            vec2.x,
            0f,
            vec2.y
        );
    }
}
