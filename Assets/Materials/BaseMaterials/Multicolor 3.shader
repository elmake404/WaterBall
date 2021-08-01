// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterial_MultipleVertexLights" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _MidColor ("Semishadow Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 1
      _AOFactor ("Ambient Occlusion Factor", Float) = 1
   }
   SubShader {
    Tags {"RenderType" = "Opaque"  "Queue" = "Geometry"} 
    Pass {   

         Tags { "LightMode" = "ForwardBase" } 

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
         uniform half4 _ColorMain; 
         uniform half4 _SpecColor; 
         uniform half4 _MidColor; 
         uniform half _Shininess;
         uniform half _AOFactor;
         uniform half4 unity_FogStart;
         uniform half4 unity_FogEnd;

         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 color : COLOR;
            float2 uv : TEXCOORD0;
         };
 
         struct vertexOutput 
         {
            half4 vertexLight:COLOR;
            half2 fogColorFactor:FLOAT;
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            LIGHTING_COORDS(1,2)
         };
 
         vertexOutput vert(vertexInput v) 
         {
            vertexOutput output;
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float4 outpos = UnityObjectToClipPos(v.vertex);

            half3 normalDirection = normalize(
               mul(half4(v.normal, 0.0), modelMatrixInverse).xyz);
            half3 viewDirection = normalize(_WorldSpaceCameraPos 
               - mul(modelMatrix, v.vertex).xyz);
            half3 lightDirection;
            half attenuation;
 
            attenuation = 1.0; // no attenuation
            lightDirection = normalize(_WorldSpaceLightPos0.xyz);

            half4 vertexLight = half4(0,0,0,0);

            for (int index = 0; index < 4; index++)
            {    
               half4 lightPosition = half4(unity_4LightPosX0[index], 
                  unity_4LightPosY0[index], 
                  unity_4LightPosZ0[index], 1.0);
 
               half3 vertexToLightSource = 
                   (lightPosition - mul(modelMatrix, v.vertex)).rgb;        
               half3 lightDirection = normalize(vertexToLightSource);
               half squaredDistance = 
                  dot(vertexToLightSource, vertexToLightSource);
               attenuation = 1.0 / (1.0  + 
                   unity_4LightAtten0[index] * squaredDistance);
               half diffuseReflection = 
                  attenuation * length(unity_LightColor[index].rgb) * max(0.0, 
                  dot(normalDirection, lightDirection));      
 
               vertexLight = vertexLight + unity_LightColor[index] * diffuseReflection;
               vertexLight.a = squaredDistance;
            }

            half factor = max(0.0,dot(normalDirection, lightDirection) * 0.5 + 0.5 * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess)) * length(_LightColor0) + length(vertexLight);
            half factorl = floor(factor + 0.5);

            //FOG
            half pos = length(outpos.xyz);
            half diff = unity_FogEnd.x - unity_FogStart.x;
            half invDiff = 1.0f / diff;
            output.fogColorFactor.x = clamp ((unity_FogEnd.x - pos) * invDiff, 0.0, 1.0);

            output.pos = outpos;
            output.fogColorFactor.y = clamp (lerp(factor, factor * (v.color.r - 0.5f) *2.0f, _AOFactor),0.0,1.0);

            output.vertexLight = vertexLight;
            TRANSFER_VERTEX_TO_FRAGMENT(output);


            return output;
         }
 
         half4 frag(vertexOutput input) : COLOR
         {
            half factor = input.fogColorFactor.y* LIGHT_ATTENUATION(input);

            half factorl = floor(factor  + 0.5);
            half3 tempcolshadowmid = lerp(_ColorMain,_MidColor,factor * 2.0);
            half3 tempcolmidlight = lerp(_MidColor,_SpecColor,(factor - 0.5 ) * 2.0);
            half3 tempcol = tempcolshadowmid * (1 - factorl) + tempcolmidlight * factorl;
           
            half3 finalColor = lerp(unity_FogColor.rgb, tempcol.rgb, input.fogColorFactor.x);
            finalColor = lerp(finalColor.rgb, input.vertexLight.rgb, 1 - input.vertexLight.a / 1000.0f );
            half4 col = half4(finalColor, 1.0f) ;
            return col;
         }
 
         ENDCG
      }
//      Pass {
//            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
//            Blend One One                                           // Additively blend this pass with the previous one(s). This pass gets run once per pixel light.
//            CGPROGRAM
//                #pragma vertex vert
//                #pragma fragment frag
//                #pragma multi_compile_fwdadd                        // This line tells Unity to compile this pass for forward add, giving attenuation information for the light.
//                
//                #include "UnityCG.cginc"
//                #include "AutoLight.cginc"
//                uniform float4 _ColorMain; 
//                uniform float4 _SpecColor; 
//                uniform float4 _MidColor;
//                 
//                struct v2f
//                {
//                    float4  pos         : SV_POSITION;
//                    float2  uv          : TEXCOORD0;
//                    float3  lightDir    : TEXCOORD2;
//                    float3 normal       : TEXCOORD1;
//                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
//                };
// 
//                v2f vert (appdata_tan v)
//                {
//                    v2f o;
//                    
//                    o.pos = mul( UNITY_MATRIX_MVP, v.vertex);
//                    o.uv = v.texcoord.xy;
//                    
//                    o.lightDir = ObjSpaceLightDir(v.vertex);
//                    
//                    o.normal =  v.normal;
//                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
//                    return o;
//                }
// 
//                fixed4 _Color;
// 
//                fixed4 _LightColor0; // Colour of the light used in this pass.
// 
//                fixed4 frag(v2f i) : COLOR
//                {
//                    i.lightDir = normalize(i.lightDir);
//                    
//                    fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
// 
//                   
//                    fixed3 normal = i.normal;                    
//                    fixed diff = saturate(dot(normal, i.lightDir));
//                    
//                    
//                    fixed4 c;
//                    c.rgb = _SpecColor * ( _LightColor0.rgb * diff) * (atten * 2); // Diffuse and specular.
//                    return c;
//                }
//            ENDCG
//        }
 
    }
 
   Fallback "VertexLit"
}