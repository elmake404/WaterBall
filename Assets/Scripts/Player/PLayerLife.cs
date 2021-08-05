using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerLife : MonoBehaviour
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
        if (collision.gameObject.layer == 7)
        {
            GameStage.Instance.ChangeStage(Stage.LostGame);
            _rbMain.constraints = RigidbodyConstraints.None;
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        Crystal crystal = other.GetComponent<Crystal>();
        if (crystal!=null)
        {
            GetCrystal?.Invoke(1);
            crystal.Collection() ;
        }
        if (other.tag == "Finish")
        {
            other.GetComponent<Finish>().Win();
            GameStage.Instance.ChangeStage(Stage.WinGame);
        }
    }
}
