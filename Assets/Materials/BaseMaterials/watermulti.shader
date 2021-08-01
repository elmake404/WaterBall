// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Transparent water MultiLights" {
   Properties {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
      _FresnelBias ("FresnelBias", Float) = 1
      _FresnelPower ("FresnelPower", Float) = 1
   }

   SubShader {
      Tags { "Queue" = "Transparent" "RenderType" = "Transparent"}
      Pass {    
         //Tags {"RenderType" = "Transparent" }
         Blend SrcAlpha OneMinusSrcAlpha
            // pass for ambient light and first light source
            //Cull Off
            ZTest LEqual
            ZWrite Off
         CGPROGRAM
    #include "UnityCG.cginc"
   #include "WaterInclude.cginc"
         #pragma vertex vert  
         #pragma fragment frag 

         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;
         uniform float _FresnelBias;
         uniform float _FresnelPower;

         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 col : COLOR;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float4 outpos = UnityObjectToClipPos(input.vertex);

            float3 normalDirection = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            float3 viewDirection = normalize(_WorldSpaceCameraPos 
               - mul(modelMatrix, input.vertex).xyz);
            float3 lightDirection;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
                  - mul(modelMatrix, input.vertex).xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
 
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _Color.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            float3 specularReflection;
            if (dot(normalDirection, lightDirection) < 0.0) 
               // light source on the wrong side?
            {
               specularReflection = float3(0.0, 0.0, 0.0); 
                  // no specular reflection
            }
            else // light source on the right side
            {
               specularReflection = attenuation * _LightColor0.rgb 
                  * _SpecColor.rgb * pow(max(0.0, dot(
                  reflect(-lightDirection, normalDirection), 
                  viewDirection)), _Shininess);
            }
            half refl2Refr = Fresnel(-viewDirection, normalDirection, _FresnelBias, _FresnelPower);
            output.col = float4(ambientLighting + diffuseReflection 
               + specularReflection,pow(max(0.0, 1.0 - dot(
                  normalDirection, 
                  viewDirection)), _FresnelPower));
            output.pos = outpos;
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            return input.col;
         }
 
         ENDCG
      }

   }
      Fallback "VertexLit"
}