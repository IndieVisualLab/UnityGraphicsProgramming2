using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;

[System.Serializable]
public class Circle
{
    public float Curvature
    {
        get { return 1f / this.radius; }
    }
    public Complex Complex
    {
        get; private set;
    }
    public float Radius
    {
        get { return Mathf.Abs(this.radius); }
    }
    public Vector2 Position
    {
        get { return this.Complex.Vec2; }
    }

    private float radius = 0f;
    
    
    public Circle(Complex complex, float radius)
    {
        this.radius = radius;
        this.Complex = complex;
    }

    public bool IsMatch(Circle c, float accuracy)
    {
        return (this.Position - c.Position).sqrMagnitude <= accuracy * accuracy;
    }

    public bool IsSeperated(Circle c)
    {
        var d = (this.Position - c.Position).sqrMagnitude;
        return d > Mathf.Pow(this.Radius + c.Radius, 2);
    }

    public bool IsIntersect(Circle c)
    {
        var d = (this.Position - c.Position).sqrMagnitude;
        return Mathf.Pow(this.Radius - c.Radius, 2) < d && d < Mathf.Pow(this.Radius + c.Radius, 2);
    }

    public bool IsInside(Circle c)
    {
        var d = (this.Position - c.Position).sqrMagnitude;
        return d < Mathf.Pow(this.Radius - c.Radius, 2);
    }
    
    public bool IsCircumscribed(Circle c, float accuracy)
    {
        var d = (this.Position - c.Position).sqrMagnitude;
        var abs = Mathf.Abs(d - Mathf.Pow(this.Radius + c.Radius, 2));

        return abs <= accuracy * accuracy;
    }

    public bool IsInscribed(Circle c, float accuracy)
    {
        var d = (this.Position - c.Position).sqrMagnitude;
        var abs = Mathf.Abs(d - Mathf.Pow(this.Radius - c.Radius, 2));

        return abs <= accuracy * accuracy;
    }
}
