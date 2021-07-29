using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMove : MonoBehaviour
{
    private Transform _playerTransform;
    private Vector3 _target
    {
        get
        {
            if (_playerTransform == null)
            {
                Transform target = PlayerMove.TransformPlayer;
                if (target == null)
                {
                    enabled = false;
                    return Vector3.zero;
                }
                else
                    _playerTransform = target.transform;
            }

            return new Vector3(_playerTransform.position.x, transform.position.y, _playerTransform.position.z);
        }
    }
    private Vector3 _velocity, _offSet;
    [SerializeField]
    private float _cameraSmoothness;

    void Start()
    {
        _offSet = _target - transform.position;
    }

    void FixedUpdate()
    {
        transform.position = Vector3.SmoothDamp(transform.position, _target - _offSet, ref _velocity, _cameraSmoothness);
    }
}
