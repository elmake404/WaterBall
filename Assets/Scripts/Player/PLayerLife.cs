using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PLayerLife : MonoBehaviour
{
    private Rigidbody _rbMain;

    private void Start()
    {
        _rbMain = GetComponent<Rigidbody>();
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.layer==6)
        {
            GameStage.Instance.ChangeStage(Stage.LostGame);
            _rbMain.constraints = RigidbodyConstraints.None;
        }
    }
}
