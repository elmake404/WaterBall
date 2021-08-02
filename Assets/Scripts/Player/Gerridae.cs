using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gerridae : MonoBehaviour
{
    [SerializeField]
    private ParticleSystem _particleWaterTouch;
    private PlayerMove _playerMove;
    private Rigidbody _rbMain;
    private List<GameObject> _waters = new List<GameObject>();

    private void Start()
    {
        _playerMove = GetComponent<PlayerMove>();
        _rbMain = GetComponent<Rigidbody>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            _waters.Add(other.gameObject);
            if (!_rbMain.useGravity && _particleWaterTouch != null)
                Instantiate(_particleWaterTouch, transform.position, transform.rotation);

            WaterTest();
        }
    }
    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            if (_rbMain.velocity.y < 0 && !_playerMove.IsDrowning)
            {
                _rbMain.velocity = Vector3.Slerp(_rbMain.velocity, Vector3.zero, 0.7f);
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            _waters.Remove(other.gameObject);

            WaterTest();
        }
    }
    private void WaterTest()
    {
        if (_waters.Count > 0)
            _rbMain.useGravity = false;
        else
            _rbMain.useGravity = true;
    }

}
