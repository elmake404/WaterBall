using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CanvasManager : MonoBehaviour
{

    [SerializeField]
    private GameObject _menuUI, _inGameUI, _wimIU, _lostUI;
    [SerializeField]
    private Image  _levelBar;
    private Transform _finishPos;
    [SerializeField]
    private Text _textLevelWin, _textLevelCurent, _textLevelTarget;

    private void Start()
    {
        _textLevelWin.text ="Level "+ PlayerPrefs.GetInt("Level").ToString();
        _textLevelCurent.text = PlayerPrefs.GetInt("Level").ToString();
        _textLevelTarget.text = (PlayerPrefs.GetInt("Level") +1).ToString();
    }
    private void FixedUpdate()
    {
    }
    public void GameStageWindow(Stage stageGame)
    {
        switch (stageGame)
        {
            case Stage.StartGame:

                _menuUI.SetActive(true);
                _inGameUI.SetActive(false);
                break;

            case Stage.StartLevel:

                _menuUI.SetActive(false);
                _inGameUI.SetActive(true);
                break;

            case Stage.WinGame:

                _inGameUI.SetActive(false);
                _wimIU.SetActive(true);
                //впиши сюда поднятие уровня и сцены 
                break;

            case Stage.LostGame:

                _lostUI.SetActive(true);
                break;
        }
    }

}
