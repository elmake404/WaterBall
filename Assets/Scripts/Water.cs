using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Water : MonoBehaviour
{
    private List<Anchor> _anchors = new List<Anchor>();
    private Dictionary<GameObject, Anchor> _dictionaryOfAnchors = new Dictionary<GameObject, Anchor>();
    [SerializeField]
    private float _archimedesStrength;
    private void Start()
    {
       _anchors.AddRange( FindObjectsOfType<Anchor>());
        for (int i = 0; i < _anchors.Count; i++)
        {
            _dictionaryOfAnchors[_anchors[i].gameObject] = _anchors[i];
        }
    }
    private void OnTriggerStay(Collider other)
    {
        if (_dictionaryOfAnchors.ContainsKey(other.gameObject))
        {
            _dictionaryOfAnchors[other.gameObject].RbMain.AddForce(Vector3.up * _archimedesStrength, ForceMode.Acceleration);
        }
    }
}
