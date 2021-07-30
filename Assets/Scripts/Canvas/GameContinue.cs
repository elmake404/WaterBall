using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameContinue : MonoBehaviour
{
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            if (PlayerPrefs.GetInt("Scenes") < SceneManager.sceneCountInBuildSettings)
            {
                SceneManager.LoadScene(PlayerPrefs.GetInt("Scenes"));
            }
            else
            {
                PlayerPrefs.SetInt("Scenes", 1);
                PlayerPrefs.SetInt("Level", 1);

                SceneManager.LoadScene(PlayerPrefs.GetInt("Scenes"));
            }
        }
    }
}
