// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterialCurvedTextured" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _MidColor ("Semishadow Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 1
      _Flip ("Is Flipped", Float) = 0
      _AOFactor ("Ambient Occlusion Factor", Float) = 1
      _Texture ("Texture ", 2D) = "black" {}
      _CurveFactorLongitudual ("_CurveFactorLongitudual", Float) = 0.03
      _CurveFactorTangential ("_CurveFactorTangential", Float) = 0.03
      _CurveFactor ("_CurveFactor", Float) = 1.0
   }
   SubShader {
    Tags {"RenderType" = "Opaque"} 
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
         uniform fixed3 _SpecColor; 
         uniform fixed3 _MidColor; 
         uniform half _Shininess;
         uniform half _AOFactor;
         uniform half _CurveFactorLongitudual;
         uniform half _CurveFactorTangential;
         uniform fixed4 unity_FogStart;
         uniform fixed4 unity_FogEnd;
         uniform half _Flip;
         uniform sampler2D _Texture;
         uniform half _CurveFactor;
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

            //outpos.y -= outpos.z * (outpos.z + abs(outpos.x - 0.5) * abs(outpos.x - 0.5) * _CurveFactorLongitudual) * _CurveFactorTangential;
            half curveL = length(outpos) * _CurveFactor;
            outpos.y -= curveL * curveL * _CurveFactorLongitudual + curveL * abs(outpos.x - 0.5)* abs(outpos.x - 0.5) * _CurveFactorTangential;
            
            half3 normalDirection = normalize(
               mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
            half3 viewDirection = normalize(_WorldSpaceCameraPos 
               - mul(modelMatrix, v.vertex).xyz);
            half3 lightDirection;
            half attenuation;
 
            attenuation = 1.0; // no attenuation
            lightDirection = normalize(_WorldSpaceLightPos0.xyz);
 


            half factor = max(0.0,dot(normalDirection, lightDirection) * 0.5 + 0.5 * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess));

            //FOG
            half pos = length(outpos.xyz);
            half diff = unity_FogEnd.x - unity_FogStart.x;
            half invDiff = 1.0f / diff;
            output.fogColorFactor.x = clamp ((unity_FogEnd.x - pos) * invDiff, 0.0, 1.0);

            output.pos = outpos;
            output.fogColorFactor.y = lerp(factor, factor * (v.color.r - 0.5f) *2.0f, _AOFactor);

            TRANSFER_VERTEX_TO_FRAGMENT(output);

            output.uv.xy = v.texcoord.xy * half2(1 - 2 * _Flip, 1);
            return output;
         }
 
         half4 frag(vertexOutput input) : COLOR
         {
            half factor = input.fogColorFactor.y* LIGHT_ATTENUATION(input);

            half factorl = floor(factor  + 0.5);
            half3 tempcolshadowmid = lerp(_ColorMain,_MidColor,factor * 2.0);
            half3 tempcolmidlight = lerp(_MidColor,_SpecColor,(factor - 0.5 ) * 2.0);
            half3 tempcol = tempcolshadowmid * (1 - factorl) + tempcolmidlight * factorl;
            tempcol = tex2D(_Texture,input.uv.xy).rgb * tempcol;

            half3 finalColor = lerp(unity_FogColor.rgb, tempcol.rgb, input.fogColorFactor.x);
            half4 col = fixed4(finalColor, 1.0f) ;
            return col;
         }
 
         ENDCG
      }
      Pass {
            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
            Blend One One                                           // Additively blend this pass with the previous one(s). This pass gets run once per pixel light.
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdadd                        // This line tells Unity to compile this pass for forward add, giving attenuation information for the light.
                
                #include "UnityCG.cginc"
                #include "AutoLight.cginc"
                uniform fixed4 _SpecColor; 
                 
                struct v2f
                {
                    float4  pos         : SV_POSITION;
                    float3  lightDir    : TEXCOORD2;
                    float3 normal       : TEXCOORD1;
                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                };
 
                v2f vert (appdata_tan v)
                {
                    v2f o;
                    
                    o.pos = UnityObjectToClipPos( v.vertex);
                    
                    o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
                    
                    o.normal =  v.normal;
                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                    return o;
                }
 
                fixed4 _LightColor0; // Colour of the light used in this pass.
 
                half4 frag(v2f i) : COLOR
                {
                    half atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
               
                    half diff = saturate(dot(i.normal, i.lightDir));

                    half4 c;
                    c.rgb = _SpecColor * ( _LightColor0.rgb * diff) * (atten * 2); // Diffuse and specular.
                    return c;
                }
            ENDCG
        }
 
    }
 
   Fallback "VertexLit"
}