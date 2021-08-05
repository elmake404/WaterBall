using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Finish : MonoBehaviour
{
    [SerializeField]
    private ParticleSystem _particleFinish;
    public void Win()
    {
        if(_particleFinish!=null)
        _particleFinish.Play();
    }
}
