using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModellBall : MonoBehaviour
{
    private PlayerMove _playerMove;

    [SerializeField]
    private float _speedRotationMax, _decelerationRotation, _accelerationRotation;
    [SerializeField]
    private float _speedRotation;
    private void Start()
    {
        _playerMove = PlayerMove.TransformPlayer.GetComponent<PlayerMove>();
    }
    private void FixedUpdate()
    {
        RotationBall();
    }
    private void RotationBall()
    {
        if (_playerMove.IsDrowning)
        {
            _speedRotation = Mathf.Lerp(_speedRotation, 0, _decelerationRotation);
        }
        else
        {
            _speedRotation = Mathf.Lerp(_speedRotation, _speedRotationMax, _accelerationRotation);
        }

        transform.Rotate(Vector3.right * _speedRotation);
    }
}
