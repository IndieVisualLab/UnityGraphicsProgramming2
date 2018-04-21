using UnityEngine;


namespace GPUBasedTrails
{
    public class RotY : MonoBehaviour
    {

        public float _speed = 1f;

        void Update()
        {
            var rot = transform.eulerAngles;
            rot.y += _speed * Time.deltaTime;
            transform.rotation = Quaternion.Euler(rot);
        }
    }
}