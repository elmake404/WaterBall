using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ZeroLevel : MonoBehaviour
{
    private void Start()
    {
        if (PlayerPrefs.GetInt("Scenes")<=0)
        {
            PlayerPrefs.SetInt("Scenes", 1);
        }
        if (PlayerPrefs.GetInt("Level") <=0)
        {
            PlayerPrefs.SetInt("Level", 1);
        }

        if (PlayerPrefs.GetInt("Scenes") < SceneManager.sceneCountInBuildSettings)
        {
            SceneManager.LoadScene(PlayerPrefs.GetInt("Scenes"));
        }
        else
        {
            PlayerPrefs.SetInt("Scenes", 1);
            SceneManager.LoadScene(PlayerPrefs.GetInt("Scenes"));
        }
    }

}
