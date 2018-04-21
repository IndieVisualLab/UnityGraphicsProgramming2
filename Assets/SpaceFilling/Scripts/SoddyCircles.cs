using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System;

public class SoddyCircles {
    public static float CalculateAccuracy = 0.1f;

    public Circle Circle1 { get; private set; }
    public Circle Circle2 { get; private set; }
    public Circle Circle3 { get; private set; }


    public SoddyCircles(Circle c1, Circle c2, Circle c3)
    {
        this.Circle1 = c1;
        this.Circle2 = c2;
        this.Circle3 = c3;
    }

    public List<SoddyCircles> GetSoddyCircles(Circle c4, Circle c5)
    {
        return new List<SoddyCircles>(this.GetSoddyCircles(c4).Concat(this.GetSoddyCircles(c5)));
    }

    public List<SoddyCircles> GetSoddyCircles(Circle c)
    {
        return c == null ?
            new List<SoddyCircles>() :
            new List<SoddyCircles>
            {
                new SoddyCircles(this.Circle1, this.Circle2, c),
                new SoddyCircles(this.Circle2, this.Circle3, c),
                new SoddyCircles(this.Circle3, this.Circle1, c)
            };
    }

    public void GetApollonianGaskets(out Circle c4, out Circle c5)
    {
        var k1 = this.Circle1.Curvature;
        var k2 = this.Circle2.Curvature;
        var k3 = this.Circle3.Curvature;

        var plusK = k1 + k2 + k3 + 2f * Mathf.Sqrt(k1 * k2 + k2 * k3 + k3 * k1);
        var minusK = k1 + k2 + k3 - 2f * Mathf.Sqrt(k1 * k2 + k2 * k3 + k3 * k1);

        var ck1 = Complex.Multiply(this.Circle1.Complex, k1);
        var ck2 = Complex.Multiply(this.Circle2.Complex, k2);
        var ck3 = Complex.Multiply(this.Circle3.Complex, k3);

        var plusZ = ck1 + ck2 + ck3 + Complex.Multiply(Complex.Sqrt(ck1 * ck2 + ck2 * ck3 + ck3 * ck1), 2f);
        var minusZ = ck1 + ck2 + ck3 - Complex.Multiply(Complex.Sqrt(ck1 * ck2 + ck2 * ck3 + ck3 * ck1), 2f);
        
        this.GetGasket(
            new Circle(Complex.Divide(plusZ, plusK), 1f / plusK),
            new Circle(Complex.Divide(minusZ, plusK), 1f / plusK),
            out c4
        );

        this.GetGasket(
            new Circle(Complex.Divide(plusZ, minusK), 1f / minusK),
            new Circle(Complex.Divide(minusZ, minusK), 1f / minusK),
            out c5
        );
    }

    private void GetGasket(Circle p1, Circle p2, out Circle c)
    {
        c = null;

        if(this.CheckGasket(p1))
        {
            c = p1;
        }
        else if(this.CheckGasket(p2))
        {
            c = p2;
        }
    }

    private bool CheckGasket(Circle p)
    {
        var c1 = this.Circle1;
        var c2 = this.Circle2;
        var c3 = this.Circle3;

        return (
            (c1.IsCircumscribed(p, CalculateAccuracy) || c1.IsInscribed(p, CalculateAccuracy)) &&
            (c2.IsCircumscribed(p, CalculateAccuracy) || c2.IsInscribed(p, CalculateAccuracy)) &&
            (c3.IsCircumscribed(p, CalculateAccuracy) || c3.IsInscribed(p, CalculateAccuracy))
        );
    }
}
