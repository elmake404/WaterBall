using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gerridae : MonoBehaviour
{
    private Rigidbody _rbMain;
    private List<GameObject> _waters = new List<GameObject>();

    private void Start()
    {
        _rbMain = GetComponent<Rigidbody>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            _waters.Add(other.gameObject);

            WaterTest();
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
