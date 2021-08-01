// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterialTranslucentEarly" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _MidColor ("Semishadow Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 1
      _Transparency ("Transparency", Float) = 1
      _AOFactor ("Ambient Occlusion Factor", Float) = 1
   }
   SubShader {
      Tags {"Queue"="Transparent-1" "RenderType" = "Transparent"}

      Pass {    
        Tags { "LightMode" = "ForwardBase" } 
         Blend SrcAlpha OneMinusSrcAlpha
         ZTest LEqual
         ZWrite Off

         CGPROGRAM
 
         #pragma vertex vert approxview
         #pragma fragment frag 
         #pragma multi_compile_fog
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
         uniform float _AOFactor;
         uniform float _Transparency;
         uniform half4 unity_FogStart;
         uniform half4 unity_FogEnd;

         struct vertexOutput 
         {
            
            float2 fogColorFactor:FLOAT;
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
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

            //outpos.y -= outpos.z * (outpos.z + abs(outpos.x - 0.5) * abs(outpos.x - 0.5) * 0.03) * 0.03;

            float3 normalDirection = normalize(
               mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
            float3 viewDirection = normalize(_WorldSpaceCameraPos 
               - mul(modelMatrix, v.vertex).xyz);
            float3 lightDirection;
            float attenuation;
 
            attenuation = 1.0; // no attenuation
            lightDirection = normalize(_WorldSpaceLightPos0.xyz);


            float factor = max(0.0,dot(normalDirection, lightDirection) * 0.5 + 0.5 * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess));
            float factorl = floor(factor + 0.5);

            //FOG
            float pos = length(outpos.xyz);
            float diff = unity_FogEnd.x - unity_FogStart.x;
            float invDiff = 1.0f / diff;
            output.fogColorFactor.x = clamp ((unity_FogEnd.x - pos) * invDiff, 0.0, 1.0);

            output.pos = outpos;
            output.fogColorFactor.y = lerp(factor, factor * (v.color.r - 0.5f) *2.0f, _AOFactor);

            TRANSFER_VERTEX_TO_FRAGMENT(output);


            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float factor = input.fogColorFactor.y* LIGHT_ATTENUATION(input);

            float factorl = floor(factor  + 0.5);
            float3 tempcolshadowmid = lerp(_ColorMain,_MidColor,factor * 2.0);
            float3 tempcolmidlight = lerp(_MidColor,_SpecColor,(factor - 0.5 ) * 2.0);
            float3 tempcol = tempcolshadowmid * (1 - factorl) + tempcolmidlight * factorl;
           
            float3 finalColor = lerp(unity_FogColor.rgb, tempcol.rgb, input.fogColorFactor.x);
            float4 col = float4(finalColor, _Transparency) ;
            return col;
         }
 
         ENDCG
      }
//       Pass {
//            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
//            Blend One One                                           // Additively blend this pass with the previous one(s). This pass gets run once per pixel light.
//            CGPROGRAM
//                #pragma vertex vert approxview
//                #pragma fragment frag
//                #pragma multi_compile_fwdadd                        // This line tells Unity to compile this pass for forward add, giving attenuation information for the light.
//                #pragma fragmentoption ARB_precision_hint_fastest
//
//                #include "UnityCG.cginc"
//                #include "AutoLight.cginc"
//                uniform fixed4 _SpecColor; 
//                uniform float _Transparency; 
//                struct v2f
//                {
//                    float4  pos         : SV_POSITION;
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
//                    
//                    o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
//                    
//                    o.normal =  v.normal;
//                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
//                    return o;
//                }
// 
//                fixed4 _LightColor0; // Colour of the light used in this pass.
// 
//                half4 frag(v2f i) : COLOR
//                {
//                    half atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
//               
//                    half diff = saturate(dot(i.normal, i.lightDir));
//
//                    half4 c;
//                    c.rgb = _Transparency * _SpecColor * ( _LightColor0.rgb * diff) * (atten* 2); // Diffuse and specular.
//                    return c;
//                }
//            ENDCG
//        }

    }
 
   Fallback "VertexLit"
}