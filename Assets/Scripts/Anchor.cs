using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anchor : MonoBehaviour
{
    [SerializeField]
    private BoxCollider _boxCollider;
    [SerializeField]
    private Rigidbody _rbMain; public Rigidbody RbMain { get { return _rbMain; } }
    [SerializeField]
    private FixedJoint _fixedJoint;
    public Vector3 _sizeCollider { get { return _boxCollider.size; } }

    public void ConnectJoint(Rigidbody rigidbody)
    {
        _fixedJoint.connectedBody = rigidbody;
    }
}
