using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMove : MonoBehaviour
{
    public static Transform TransformPlayer;

    private Rigidbody _rbMain;
    [SerializeField]
    private Vector3 _DirectionMove = Vector3.forward;
    [SerializeField]
    private Anchor _anchor;
    [SerializeField]
    private int _namberAnchor;
    [SerializeField]
    private float _speed;
    private bool _isDrowning;
    private void Awake()
    {
        TransformPlayer = transform;
    }
    private void Start()
    {
        _rbMain = GetComponent<Rigidbody>();
    }
    private void FixedUpdate()
    {
        transform.Translate(_DirectionMove*_speed);
    }

    private void Update()
    {
        if (TouchUtility.TouchCount > 0)
        {
            Touch touch = TouchUtility.GetTouch(0);
            if (touch.phase == TouchPhase.Moved)
            {
                _isDrowning = true;
                _rbMain.velocity = Vector3.down*10;
            }
        }
        else
        {
            _isDrowning = false;
        }
    }
    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            if (_rbMain.velocity.y < 0 && !_isDrowning)
            {
                _rbMain.velocity = Vector3.Slerp(_rbMain.velocity, Vector3.zero, 0.7f);
            }
        }
    }
    [ContextMenu("Creating Anchors")]
    private void CreatingAnchors()
    {
        float angle = 360 / _namberAnchor;
        float rotation = 0;

        for (int i = 0; i < _namberAnchor; i++)
        {
            Anchor anchor = Instantiate(_anchor, transform);
            anchor.transform.localEulerAngles = new Vector3(rotation, 0, 0);
            anchor.transform.localPosition = Vector3.zero;
            anchor.transform.Translate(Vector3.up * ((transform.localScale.y - _anchor._sizeCollider.y) / 2));
            anchor.ConnectJoint(_rbMain);
            rotation += angle;
        }
    }
}
