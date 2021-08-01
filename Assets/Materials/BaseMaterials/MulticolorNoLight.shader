// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterialNoLight" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _MidColor ("Semishadow Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 1
   }
   SubShader {
    Tags { "RenderType" = "Opaque"} 
    Pass {   

         Tags { "LightMode" = "ForwardBase" } 
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
         #pragma multi_compile_fwdbase
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma fragmentoption ARB_fog_linear
         #pragma glsl_no_auto_normalization

         #include "AutoLight.cginc"
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 

         uniform float4 _ColorMain; 
         uniform float4 _SpecColor; 
         uniform float4 _MidColor; 
         uniform float _Shininess;

         struct vertexOutput {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            LIGHTING_COORDS(1,2)
            float4 col : COLOR;

         };
 
         vertexOutput vert(appdata_full v) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float4 outpos = UnityObjectToClipPos(v.vertex);

            float3 normalDirection = normalize(
               mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
            float3 viewDirection = normalize(_WorldSpaceCameraPos 
               - mul(modelMatrix, v.vertex).xyz);
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
                  - mul(modelMatrix, v.vertex).xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _ColorMain.rgb;
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _ColorMain.rgb
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
 
            output.col = float4(ambientLighting + diffuseReflection 
               + specularReflection, 1.0);
            float factor = max(0.0,dot(normalDirection, lightDirection) * 0.5 + 0.5 * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess));
            float factorl = floor(factor + 0.5);
            half3 tempcolshadowmid = lerp(_ColorMain,_MidColor,factor * 2.0);
            half3 tempcolmidlight = lerp(_MidColor,_SpecColor,(factor - 0.5 ) * 2.0);
            half3 tempcol = tempcolshadowmid * (1 - factorl) + tempcolmidlight * factorl;
            output.col = half4(tempcol.rgb,1.0);
            output.pos = outpos;
            TRANSFER_VERTEX_TO_FRAGMENT(output);


            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float4 col = input.col * LIGHT_ATTENUATION(input);
            return col;
         }
 
         ENDCG
      }
      Pass {
            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
            Blend Off                                          // Additively blend this pass with the previous one(s). This pass gets run once per pixel light.
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdadd                        // This line tells Unity to compile this pass for forward add, giving attenuation information for the light.
                
                #include "UnityCG.cginc"
                #include "AutoLight.cginc"
                uniform float4 _ColorMain; 
                uniform float4 _SpecColor; 
                uniform float4 _MidColor;
                 
                struct v2f
                {
                    float4  pos         : SV_POSITION;
                    float2  uv          : TEXCOORD0;
                    float3  lightDir    : TEXCOORD2;
                    float3 normal       : TEXCOORD1;
                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                };
 
                v2f vert (appdata_tan v)
                {
                    v2f o;
                    
                    o.pos = UnityObjectToClipPos( v.vertex);
                    o.uv = v.texcoord.xy;
                    
                    o.lightDir = ObjSpaceLightDir(v.vertex);
                    
                    o.normal =  v.normal;
                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                    return o;
                }
 
                fixed4 _Color;
 
                fixed4 _LightColor0; // Colour of the light used in this pass.
 
                fixed4 frag(v2f i) : COLOR
                {
                    fixed4 c;
                    c.rgb = _SpecColor * _LightColor0.rgb  * 0; // Diffuse and specular.
                    c.a = 1.0f;
                    return c;
                }
            ENDCG
        }
 
    }
 
   Fallback "VertexLit"
}