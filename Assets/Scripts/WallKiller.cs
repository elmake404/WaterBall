using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WallKiller : MonoBehaviour
{
    [SerializeField]
    private float _speedMove;
    [SerializeField]
    private Vector3 _directionMove;

    private void FixedUpdate()
    {
        if (GameStage.IsGameFlowe)
        {
            transform.Translate(_directionMove*_speedMove);
        }
    }
}
