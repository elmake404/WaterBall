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
    private Animator _animator;
    [SerializeField]
    private Anchor _anchor;
    [SerializeField]
    private ParticleSystem _particleBubbles;
    [SerializeField]
    private int _namberAnchor;
    [SerializeField]
    private float _speedMove, _sinkingSpeed;
    public bool IsDrowning { get; private set; }
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
        if (GameStage.IsGameFlowe)
            transform.Translate(_DirectionMove * _speedMove);
    }

    private void Update()
    {
        //if (TouchUtility.TouchCount > 0)
        //{
        Touch touch = TouchUtility.GetTouch(0);
        if (touch.phase == TouchPhase.Began)
        {
            _animator.SetBool("deflate", true);
        }
        else if (touch.phase == TouchPhase.Moved)
        {
            IsDrowning = true;
            _rbMain.velocity = Vector3.down * _sinkingSpeed;
        }
        else if (touch.phase==TouchPhase.Ended)
        {
            if (_particleBubbles != null)
                _particleBubbles.Stop();

            _animator.SetBool("deflate", false);

            IsDrowning = false;
        }
        //}
        //else
        //{
        //    if (_particleBubbles != null)
        //        _particleBubbles.Stop();

        //    IsDrowning = false;
        //}
    }
    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.layer == 4)
        {
            if (IsDrowning && _particleBubbles != null)
            {
                if (!_particleBubbles.isPlaying)
                    _particleBubbles.Play();
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
