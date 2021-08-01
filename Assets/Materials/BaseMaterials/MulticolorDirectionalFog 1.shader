// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterialAnisotropicFogY" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _FogScaleZ ("Fog Scale Z", Float) = 10
      _FogPowerZ("Fog Power", Float) = 2
      _FogOffsetY("Fog Offset Y", Float) = 1
      _GlobalLightIntensity("Global Light Intensity", Float) = 1
   }
   SubShader {
    Tags {"Queue"="Geometry"} 
    Pass {   

         Tags { "LightMode" = "ForwardBase" } 

         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
         #pragma multi_compile_fog
         #pragma multi_compile_fwdbase
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma fragmentoption ARB_fog_linear
         #pragma glsl_no_auto_normalization


         #include "AutoLight.cginc"
         #include "UnityCG.cginc"
         uniform fixed4 _LightColor0; 

         uniform fixed3 _ColorMain; 
         uniform half _FogScaleZ;
         uniform half _FogPowerZ;
         uniform half _FogOffsetY;
         uniform fixed4 unity_FogStart;
         uniform fixed4 unity_FogEnd;
         uniform half _GlobalLightIntensity;

         struct vertexOutput 
         {
            
            half2 fogColorFactor:FLOAT;
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            LIGHTING_COORDS(1,2)
         };
 
         vertexOutput vert(appdata_full v) 
         {
            vertexOutput output;
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float4 outpos = UnityObjectToClipPos(v.vertex);
 
            //FOG
            half height = mul(modelMatrix, v.vertex).y;
            half pos = (height - _FogOffsetY) / _FogScaleZ;//* lerp(_FogPowerZ,1, height / _FogScaleZ);
            output.fogColorFactor.x = clamp (pos, 0.0, 1.0f);

            output.pos = outpos;

            return output;
         }
 
         half4 frag(vertexOutput input) : COLOR
         {
           
            half3 finalColor = lerp(unity_FogColor.rgb, _ColorMain.rgb, input.fogColorFactor.x);
            half4 col = half4(finalColor, 1.0f) * _GlobalLightIntensity;
            return col;
         }
 
         ENDCG
      }
    }
 
   Fallback "VertexLit"
}