using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PLayerLife : MonoBehaviour
{
    public delegate void CollectorInt(int namber);
    public event CollectorInt GetCrystal;
    private Rigidbody _rbMain;

    private void Start()
    {
        _rbMain = GetComponent<Rigidbody>();
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.layer == 6)
        {
            GameStage.Instance.ChangeStage(Stage.LostGame);
            _rbMain.constraints = RigidbodyConstraints.None;
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Crystal")
        {
            GetCrystal?.Invoke(1);
            Destroy(other.gameObject);
        }
    }
}
