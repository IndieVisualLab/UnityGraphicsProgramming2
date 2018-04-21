using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Globalization;

[Serializable]
public struct Complex
{
    public static readonly Complex Zero = new Complex(0f, 0f);
    public static readonly Complex One = new Complex(1f, 0f);
    public static readonly Complex ImaginaryOne = new Complex(0f, 1f);

    public float Real
    {
        get { return this.real; }
    }
    public float Imaginary
    {
        get { return this.imaginary; }
    }
    public float Magnitude
    {
        get { return Abs(this); }
    }
    public float SqrMagnitude
    {
        get { return SqrAbs(this); }
    }
    public float Phase
    {
        get { return Mathf.Atan2(this.imaginary, this.real); }
    }
    public Vector2 Vec2
    {
        get { return new Vector2(this.real, this.imaginary); }
    }

    [SerializeField]
    private float real;
    [SerializeField]
    private float imaginary;


    public Complex(Vector2 vec2) : this(vec2.x, vec2.y) { }

    public Complex(Complex other) : this(other.real, other.imaginary) { }

    public Complex(float real, float imaginary)
    {
        this.real = real;
        this.imaginary = imaginary;
    }

    public override string ToString()
    {
        return String.Format(CultureInfo.CurrentCulture, "({0}, {1})", this.real, this.imaginary);
    }

    #region "Static Methods"
    public static Complex FromPolarCoordinates(float magnitude, float phase)
    {
        return new Complex(magnitude * Mathf.Cos(phase), magnitude * Mathf.Sin(phase));
    }

    public static Complex Conjugate(Complex complex)
    {
        return new Complex(complex.real, -complex.imaginary);
    }

    public static Complex Negate(Complex complex)
    {
        return -complex;
    }
    public static Complex Add(Complex left, Complex right)
    {
        return left + right;
    }

    public static Complex Subtract(Complex left, Complex right)
    {
        return left - right;
    }

    public static Complex Multiply(Complex left, Complex right)
    {
        return left * right;
    }

    public static Complex Multiply(Complex left, float right)
    {
        return new Complex(left.real * right, left.imaginary * right);
    }

    public static Complex Divide(Complex dividend, Complex divisor)
    {
        return dividend / divisor;
    }

    public static Complex Divide(Complex dividend, float divisor)
    {
        return new Complex(dividend.real / divisor, dividend.imaginary / divisor);
    }

    public static Complex Sqrt(Complex complex)
    {
        return FromPolarCoordinates(Mathf.Sqrt(complex.Magnitude), complex.Phase / 2f);
    }

    public static float SqrAbs(Complex complex)
    {
        if(float.IsInfinity(complex.real) == true || float.IsInfinity(complex.imaginary) == true)
        {
            return float.PositiveInfinity;
        }

        return complex.real * complex.real + complex.imaginary * complex.imaginary;
    }
    
    public static float Abs(Complex complex)
    {
        if(float.IsInfinity(complex.real) == true || float.IsInfinity(complex.imaginary) == true)
        {
            return float.PositiveInfinity;
        }

        var r = Mathf.Abs(complex.real);
        var i = Mathf.Abs(complex.imaginary);

        if(r > i)
        {
            var d = i / r;
            return r * Mathf.Sqrt(1f + d * d);
        }
        else if(i == 0f)
        {
            return r;
        }
        else
        {
            var d = r / i;
            return i * Mathf.Sqrt(1f + d * d);
        }
    }
    #endregion

    #region "Operators"
    public static Complex operator -(Complex complex)
    {
        return new Complex(-complex.real, -complex.imaginary);
    }

    public static Complex operator +(Complex left, Complex right)
    {
        return new Complex(left.real + right.real, left.imaginary + right.imaginary);
    }

    public static Complex operator -(Complex left, Complex right)
    {
        return new Complex(left.real - right.real, left.imaginary - right.imaginary);
    }
    
    public static Complex operator *(Complex left, Complex right)
    {
        // (a + bi) * (c + di) = (ac - bd) + (bc + ad)i
        var real = (left.real * right.real) - (left.imaginary * right.imaginary);
        var imaginary = (left.imaginary * right.real) + (left.real * right.imaginary);

        return new Complex(real, imaginary);
    }

    public static Complex operator /(Complex left, Complex right)
    {
        var denominator = right.SqrMagnitude;
        if(denominator == 0f || float.IsInfinity(denominator) == true)
        {
            return Zero;
        }

        return new Complex(
            (left.real * right.real + left.imaginary * right.imaginary) / denominator,
            (right.real * left.imaginary - left.real * right.imaginary) / denominator
        );
    }
    #endregion
}
