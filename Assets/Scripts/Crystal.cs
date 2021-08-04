using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Crystal : MonoBehaviour
{
    [SerializeField]
    private ParticleSystem _particle—ollection;
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
        if (_particle—ollection != null)
            Instantiate(_particle—ollection, transform.position, Quaternion.identity);

        Destroy(gameObject);
    }
}
