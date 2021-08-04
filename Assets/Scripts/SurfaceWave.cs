﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SurfaceWave : MonoBehaviour {
    [SerializeField] WaterInteractionTrigger waterInteractionTrigger;

    [SerializeField]
    Renderer m_targetRenderer;
    [SerializeField]
    Material m_equationMaterial;
    Material m_surfaceMaterial;

    [SerializeField]
    int m_inputTextureWidth = 64;
    [SerializeField]
    int m_inputTextureHeight = 64;
    Texture2D m_inputTexture;

    [SerializeField]
    int m_textureWidth = 256;
    [SerializeField]
    int m_textureHeight = 256;
    RenderTexture[] m_renderTextures = new RenderTexture[3];

    Vector2 m_hitPoint;
    bool m_hasClick;
    RaycastHit m_hit;

    int m_textureIdx = 0;
    RenderTexture m_currentFrame {
        get {
            return m_renderTextures[m_textureIdx];
        }
    }
    RenderTexture m_prevFrame {
        get {
            return m_renderTextures[(m_textureIdx + 2) % 3];
        }
    }
    RenderTexture m_prevPrevFrame {
        get {
            return m_renderTextures[(m_textureIdx + 1) % 3];
        }
    }

    void Awake () {
        waterInteractionTrigger.OnWaterInteraction += DownRayCast;

        m_equationMaterial.SetVector ("_Stride", new Vector2 (1f / m_textureWidth, 1f / m_textureHeight));
        m_equationMaterial.SetFloat ("_RoundAdjuster", -0.5f/255f);
        m_surfaceMaterial = m_targetRenderer.sharedMaterial;
        m_surfaceMaterial.SetVector ("_Stride", new Vector2 (1f / m_textureWidth, 1f / m_textureHeight));

        m_inputTexture = new Texture2D (m_inputTextureWidth, m_inputTextureHeight);
        ClearInputTexture ();

        for (int i = 0; i < m_renderTextures.Length; i++) {
            m_renderTextures[i] = new RenderTexture (m_textureWidth, m_textureHeight, 0, RenderTextureFormat.ARGB32);
            m_renderTextures[i].Create();
            Graphics.SetRenderTarget(m_renderTextures[i]);
			GL.Clear(false, true, Color.gray);
        }
    }

    void OnDestory () {
        for (int i = 0; i < m_renderTextures.Length; i++) {
            m_renderTextures[i].Release ();
        }
    }

    void OnPreRender() {
        m_equationMaterial.SetTexture ("_PrevTex", m_prevFrame);
        m_equationMaterial.SetTexture ("_PrevPrevTex", m_prevPrevFrame);
        Graphics.Blit (m_inputTexture, m_currentFrame, m_equationMaterial);
        ClearInputTexture ();

        m_surfaceMaterial.SetTexture ("_WaveTex", m_currentFrame);
        m_textureIdx = (m_textureIdx + 1) % m_renderTextures.Length;
    }

    void Update () {
        if (m_hasClick) {
            m_hasClick = false;
            
            Vector2 uv = new Vector2(m_hitPoint.x , m_hitPoint.y);
            int x = Mathf.RoundToInt(m_inputTexture.width * uv.x);
            int y = Mathf.RoundToInt(m_inputTexture.height * uv.y);
            m_inputTexture.SetPixel(x, y, Color.white);
            m_inputTexture.Apply();
        }
    }

    public void DownRayCast (Vector3 orign) {
        var ray = new Ray(orign, Vector3.down);
        if (Physics.Raycast (ray, out m_hit)) {
            if (Vector3.Dot(m_hit.normal, Vector3.up) < 1.0f)
            {
                return;
            }
            m_hitPoint = m_hit.textureCoord;
            m_hasClick = true;
        }
    }

    void ClearInputTexture () {
        for (int y = 0; y < m_inputTexture.height; y++)  {
            for (int x = 0; x < m_inputTexture.width; x++) {
                m_inputTexture.SetPixel(x, y, Color.gray);
            }
        }
        m_inputTexture.Apply();
    }
}