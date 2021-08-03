using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModellBall : MonoBehaviour
{
    private PlayerMove _playerMove;

    [SerializeField]
    private float _speedRotation, _angleOfRotation;
    private Vector3 _oldPos, _currentPos;
    private List<GameObject> _waters = new List<GameObject>();

    private void Start()
    {
        _playerMove = PlayerMove.TransformPlayer.GetComponent<PlayerMove>();
        _oldPos = _playerMove.transform.position;
        _currentPos = _playerMove.transform.position;
    }
    private void FixedUpdate()
    {
        RotationBall();

        _currentPos = _playerMove.transform.position;
    }
    private void LateUpdate()
    {
        _oldPos = _playerMove.transform.position;
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            _waters.Add(other.gameObject);
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            _waters.Remove(other.gameObject);
        }
    }
    public bool WaterTest()
    {
        if (_waters.Count > 0)
            return true;
        else
            return false;
    }

    private void RotationBall()
    {
        int sensitivity;

        if (WaterTest())
            sensitivity = 2;
        else
            sensitivity = 3;

        float DirectionTravel = (float)System.Math.Round(_oldPos.y - _currentPos.y, sensitivity);
        Quaternion rotation;
        if (DirectionTravel == 0)
        {
            rotation = Quaternion.Euler(Vector3.zero);
        }
        else
        {
            if (DirectionTravel > 0)
            {
                rotation = Quaternion.Euler(Vector3.right * -_angleOfRotation);
            }
            else
            {
                rotation = Quaternion.Euler(Vector3.right * _angleOfRotation);
            }
        }

        transform.rotation = Quaternion.Slerp(transform.rotation, rotation, _speedRotation);
    }
}
