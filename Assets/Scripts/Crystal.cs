using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Crystal : MonoBehaviour
{
    [SerializeField]
    private ParticleSystem _particleÑollection;
    [SerializeField]
    private Vector3 _axisOfRotation;
    [SerializeField]
    private float _speedRotation;
    private void FixedUpdate()
    {
        transform.Rotate(_axisOfRotation * _speedRotation);
    }
    public void Collection()
    {
        if (_particleÑollection != null)
            Instantiate(_particleÑollection, transform.position, Quaternion.identity);

        Destroy(gameObject);
    }
}
