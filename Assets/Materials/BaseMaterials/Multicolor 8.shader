// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterialGlow" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _Glow ("Glow", Float) = 1
      _GlobalLightIntensity("Global Light Intensity", Float) = 1
   }
   SubShader {
    Tags {"RenderType" = "Opaque"} 
    Pass {   

         Tags { "LightMode" = "ForwardBase" } 
         Cull Off
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
         uniform half _Glow;
         uniform half _GlobalLightIntensity;

         struct vertexOutput 
         {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            LIGHTING_COORDS(1,2)
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

            output.uv = v.texcoord.xy;
            output.pos = outpos;

            TRANSFER_VERTEX_TO_FRAGMENT(output);


            return output;
         }
 
         half4 frag(vertexOutput input) : COLOR
         {
            half4 col = half4(_ColorMain * _Glow * _GlobalLightIntensity * _GlobalLightIntensity, 1.0f);
            return col;
         }
 
         ENDCG
      }
    }
 
   Fallback "Mobile/VertexLit"
}