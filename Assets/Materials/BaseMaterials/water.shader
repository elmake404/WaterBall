// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Transparent water" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
      _FresnelPower ("FresnelPower", Float) = 1
   }

   SubShader {
      Tags { "Queue" = "Transparent" "RenderType" = "Transparent"}
      Tags { "LightMode" = "ForwardBase" } 
      Pass {    
         Blend SrcAlpha OneMinusSrcAlpha
         ZTest LEqual
         ZWrite Off
         CGPROGRAM
         #include "UnityCG.cginc"
         #pragma vertex vert approxview
         #pragma fragment frag 
         #pragma multi_compile_fwdbase
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma fragmentoption ARB_fog_linear

         uniform half4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform half4 _ColorMain; 
         uniform half4 _SpecColor; 
         uniform float _Shininess;
         uniform float _FresnelPower;
         uniform half4 unity_FogStart;
         uniform half4 unity_FogEnd;

         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            half4 col : COLOR;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float4 outpos = UnityObjectToClipPos(input.vertex);

            half3 normalDirection = normalize(
               mul(half4(input.normal, 0.0), modelMatrixInverse).xyz);
            half3 viewDirection = normalize(_WorldSpaceCameraPos 
               - mul(modelMatrix, input.vertex).xyz);
            half3 lightDirection;
           lightDirection = normalize(_WorldSpaceLightPos0.xyz);
 
            half3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _ColorMain.rgb;
 
            half3 diffuseReflection = 
               _LightColor0.rgb * _ColorMain.rgb
               * max(0.0, dot(normalDirection, lightDirection));

           half3 specularReflection = _LightColor0.rgb 
              * _SpecColor.rgb * max(0.0, dot(
              reflect(-lightDirection, normalDirection), 
              viewDirection));

            //FOG
            half pos = length(outpos.xyz);
            half diff = unity_FogEnd.x - unity_FogStart.x;
            half invDiff = 1.0f / diff;
            half fogColorFactor = clamp ((unity_FogEnd.x - pos) * invDiff, 0.0, 1.0);

            half4 finalColor = lerp(unity_FogColor, half4(ambientLighting + diffuseReflection + specularReflection,pow(max(0.0, dot(normalDirection, viewDirection)), _FresnelPower)), fogColorFactor);

            output.col = finalColor;
            output.pos = outpos;
            return output;
         }
 
         half4 frag(vertexOutput input) : COLOR
         {
            return input.col;
         }
 
         ENDCG
      }

   }
      Fallback "VertexLit"
}