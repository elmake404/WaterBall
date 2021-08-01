// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterialDepthOnly" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _MidColor ("Semishadow Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 1
      _AOFactor ("Ambient Occlusion Factor", Float) = 1
      _GlobalLightIntensity("Global Light Intensity", Float) = 1
   }
   SubShader {
    Tags {"RenderType" = "Opaque" "Queue"="Geometry+1"} 
    Pass {   
         Blend Zero One
         Tags { "LightMode" = "ForwardBase" } 
         ZTest Lequal
         Zwrite On
         Cull Back
         CGPROGRAM

         #pragma vertex vert approxview
         #pragma fragment frag 
         #pragma multi_compile_fog
         #pragma multi_compile_fwdbase
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma fragmentoption ARB_fog_linear


         #include "AutoLight.cginc"
         #include "UnityCG.cginc"
         uniform half4 _LightColor0; 
         uniform half3 _ColorMain; 

         uniform half3 _SpecColor; 
         uniform half3 _MidColor; 
         uniform half _Shininess;
         uniform half _AOFactor;
         uniform half4 unity_FogStart;
         uniform half4 unity_FogEnd;
         uniform half _GlobalLightIntensity;

         struct vertexOutput 
         {
            float4 pos : SV_POSITION;
         };

         struct appdata_t
         {
            float4 vertex   : POSITION;
            float3 normal   : NORMAL;
            float4 color    : COLOR;
            float2 texcoord : TEXCOORD0;
         };

         vertexOutput vert(appdata_t v) 
         {
            vertexOutput output;
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float4 outpos = UnityObjectToClipPos(v.vertex);
            output.pos = outpos;
            return output;
         }
 
         half4 frag(vertexOutput IN):COLOR
         {
            return half4(0,0,0,1);
         }
 
         ENDCG
      }
 
    }
 
   Fallback "VertexLit"
}