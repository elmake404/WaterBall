using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainMenu : MonoBehaviour
{
    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            GameStage.Instance.ChangeStage(Stage.StartLevel);
            gameObject.SetActive(false);
        }
    }
}
