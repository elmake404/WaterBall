using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class WaterInteractionTrigger : MonoBehaviour {
	public Transform interactObject;

	public delegate void DelegateWaterInteraction(Vector3 position);
	public event DelegateWaterInteraction OnWaterInteraction;

    private void Start()
    {
		OnWaterInteraction?.Invoke(interactObject.position);
    }

    private void FixedUpdate()
    {
		OnWaterInteraction?.Invoke(interactObject.position);
	}
    /*public class OnClickEvent : UnityEvent<Vector3> { }
	public OnClickEvent onClickDown;*/


    /*void Update () {
#if UNITY_EDITOR || UNITY_STANDALONE || UNITY_WEBGL
		if (Input.GetMouseButton(0)) {
			onClickDown.Invoke (Input.mousePosition);
		}
#elif UNITY_IPHONE || UNITY_ANDROID
		if (Input.touchCount > 0) {
			Touch touch = Input.GetTouch(0);
            onClickDown.Invoke (touch.position);
		}
#endif
	}

	public void Pause () {
		this.enabled = false;
	}

	public void Resume () {
		this.enabled = true;
	}*/
}
