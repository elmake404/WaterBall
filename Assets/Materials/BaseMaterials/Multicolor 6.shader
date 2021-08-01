// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CustomMaterialSSSTransparent" {
   Properties {
      _ColorMain ("Diffuse Material Color", Color) = (1,1,1,1) 
      _MidColor ("Semishadow Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _SSSColor ("SSS Material Color", Color) = (1,1,1,1) 
      _SSSPower ("SSS Power", Float) = 1
      _Shininess ("Shininess", Float) = 1
      _AOFactor ("Ambient Occlusion Factor", Float) = 1
      _DepthTextureLight ("Texture ", 2D) = "black" {}
      _DepthTextureLight1 ("Texture ", 2D) = "black" {}
      _DepthTextureBack ("Texture ", 2D) = "black" {}
      _NoiseTexture ("NoiseTex ", 2D) = "black" {}
      _NoiseImpact ("NoiseImpact", Float) = 1
      _RefractiveIndex ("RefractiveIndex", Float) = 1
      _RefractivePower ("RefractivePower", Float) = 10
      _Fresnel_power ("_Fresnel_power", Float) = 0
      _Transparency ("Transparency", Float) = 1
      _GrabTexture_TexelSize("_GrabTexture_TexelSize",Color) = (1,1,1,1)
      _GrabScale("_GrabTexture_Scale",Float) = 1
   }
       Category {
                Tags {"Queue"="Transparent" "RenderType" = "Transparent"}
   SubShader {

 GrabPass {                     
                Tags { "LightMode" = "Always" }
            }
            Pass {
                Tags { "LightMode" = "Always" }
               
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
               
                struct appdata_t {
                    float4 vertex : POSITION;
                    float2 texcoord: TEXCOORD0;
                };
               
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                };
               
                v2f vert (appdata_t v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
                    return o;
                }
               
                sampler2D _GrabTexture;
                uniform float4 _GrabTexture_TexelSize;
                uniform float _GrabScale;
               
                half4 frag( v2f i ) : COLOR {
//                  half4 col = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
//                  return col;
                   
                    half4 sum = half4(0,0,0,0);
 
                    #define GRABPIXEL(weight,kernelx) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x + _GrabTexture_TexelSize.x * _GrabScale * kernelx, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight
 
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.18,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
                   
                    return sum;
                }
                ENDCG
            }
 
            // Vertical blur
            GrabPass {                         
                Tags { "LightMode" = "Always" }
            }
            Pass {
                Tags { "LightMode" = "Always" }
               
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
               
                struct appdata_t {
                    float4 vertex : POSITION;
                    float2 texcoord: TEXCOORD0;
                };
               
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                };
               
                v2f vert (appdata_t v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
                    return o;
                }
               
                sampler2D _GrabTexture;
                uniform float4 _GrabTexture_TexelSize;
                uniform float _GrabScale;
               
                half4 frag( v2f i ) : COLOR {
//                  half4 col = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
//                  return col;
                   
                    half4 sum = half4(0,0,0,0);
 
                    #define GRABPIXEL(weight,kernely) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _GrabTexture_TexelSize.y * _GrabScale* kernely, i.uvgrab.z, i.uvgrab.w))) * weight
 
                    //G(X) = (1/(sqrt(2*PI*deviation*deviation))) * exp(-(x*x / (2*deviation*deviation)))
                   
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.128,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
                   
                    return sum;
                }
                ENDCG
            }

                        // Distortion
            GrabPass {                         
                Tags { "LightMode" = "Always" }
            }
    Pass {   

         Tags { "LightMode" = "ForwardBase" } 
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest LEqual
            //ZWrite Off
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
         uniform half3 _SSSColor;
         uniform half _SSSPower;
         uniform half _Shininess;
         uniform half _NoiseImpact;
         uniform half _AOFactor;
         uniform half4 unity_FogStart;
         uniform half4 unity_FogEnd;
         uniform sampler2D _DepthTextureLight;
         uniform sampler2D _DepthTextureLight1;
         uniform sampler2D _DepthTextureBack;
         uniform sampler2D _NoiseTexture;
         uniform float4x4  _DepthRecoveryMatrix;
         uniform float4x4  _DepthRecoveryMatrix1;
         uniform float4x4  _DepthRecoveryMatrixBack;

         uniform half _RefractiveIndex;
         uniform half _RefractivePower;
         uniform half _Fresnel_power;
         uniform sampler2D _GrabTexture;
         uniform float _Transparency;

         struct vertexOutput 
         {
            half2 uv:TEXCOORD1;
            half2 fogColorFactor:FLOAT;
            float4 pos : SV_POSITION;
            float4 proj : TEXCOORD0;
            half4  normalColor:NORMAL;
            float4 rawPos : COLOR;
            float irradiance : HALF;
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

            half3 normalDirection = normalize(
               mul(half4(v.normal, 0.0), modelMatrixInverse).xyz);
            half3 viewDirection = normalize(_WorldSpaceCameraPos 
               - mul(modelMatrix, v.vertex).xyz);
            half3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
 
            float irradiance = max(0.5f + dot(-normalDirection, lightDirection), 0.0);
            half factor = max(0.0,dot(normalDirection, lightDirection) * 0.5 + 0.7 * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess));

            //FOG
            half pos = length(outpos.xyz);
            half diff = unity_FogEnd.x - unity_FogStart.x;
            half invDiff = 1.0f / diff;
            output.fogColorFactor.x = clamp ((unity_FogEnd.x - pos) * invDiff, 0.0, 1.0);

            output.pos = outpos;
            output.fogColorFactor.y = lerp(factor, factor * (v.color.r - 0.5f) *2.0f, _AOFactor);
//            output.depthRecoveryMatrix = _DepthRecoveryMatrix;
//            output.modelMatrix = modelMatrix;

            float3 refractedDir = refract(viewDirection, 
               normalDirection, 1.0 / _RefractiveIndex);
            output.normalColor.xyz = refractedDir;
            half refl2Refr = pow(dot(viewDirection,normalDirection),_Fresnel_power);//Fresnel(viewDirection, normalDirection, _Fresnel_bias, _Fresnel_power);
        
            #if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
            #else
                float scale = 1.0;
            #endif
            output.uv = v.texcoord.xy;
            output.proj.xy = (float2(outpos.x, outpos.y*scale) + outpos.w) * 0.5;
            output.proj.zw = outpos.zw;
            output.normalColor.w = refl2Refr;

            output.irradiance = irradiance;
            output.rawPos = v.vertex - float4(0.005f * v.normal,0);
            TRANSFER_VERTEX_TO_FRAGMENT(output);


            return output;
         }

         float4 T(float s) {
          return float4(float3(0.233, 0.455, 0.649) * exp(-s * s / 0.0064) +
                 float3(0.1,   0.336, 0.344) * exp(-s * s / 0.0484) +
                 float3(0.118, 0.198, 0.0)   * exp(-s * s / 0.187)  +
                 float3(0.113, 0.007, 0.007) * exp(-s * s / 0.567)  +
                 float3(0.358, 0.004, 0.0)   * exp(-s * s / 1.99)   +
                 float3(0.078, 0.0,   0.0)   * exp(-s * s / 7.41),1);
        }

         float4 frag(vertexOutput input) : COLOR
         {
            half    noiseScale = ((1 - _NoiseImpact) + _NoiseImpact * tex2D(_NoiseTexture,input.uv.xy * 2).r);
            half    noiseScale1 = ((1 - _NoiseImpact * 5) + _NoiseImpact* 5 * tex2D(_NoiseTexture,input.uv.xy * 2).r);
            float4 posinLightSpace = mul(_DepthRecoveryMatrix, mul(unity_ObjectToWorld, input.rawPos));
            float4 posinLightSpace1 = mul(_DepthRecoveryMatrix1, mul(unity_ObjectToWorld, input.rawPos));

            float4 posinBackSpace = mul(_DepthRecoveryMatrixBack, mul(unity_ObjectToWorld, input.rawPos));
            float4 invertedposinBackSpace = mul(- _DepthRecoveryMatrixBack, mul(unity_ObjectToWorld, input.rawPos));

            half factor = input.fogColorFactor.y * LIGHT_ATTENUATION(input)* noiseScale;

            half factorl = floor(factor  + 0.5);
            half3 tempcolshadowmid = lerp(_ColorMain,_MidColor,factor * 2.0);
            half3 tempcolmidlight = lerp(_MidColor,_SpecColor,(factor - 0.5 ) * 2.0);
            half3 tempcol = tempcolshadowmid * (1 - factorl) + tempcolmidlight * factorl;

            half3 finalColor = lerp(unity_FogColor.rgb, tempcol.rgb, input.fogColorFactor.x);

            //SSS
            float4 t = tex2D(_DepthTextureLight, posinLightSpace.xy);
            float4 t1 = tex2D(_DepthTextureLight1, posinLightSpace1.xy);
            float dist1 = abs(posinLightSpace1.z - t1.r);
            float dist = abs(posinLightSpace.z - t.r);
            float d = min(dist, dist1);
//            if (posinLightSpace.z > 0)
//                d = dist;
//            else
//                d = dist1;
            //float d = min(dist, dist1);
            float4 col = clamp(exp (-d * d * 1000 * _SSSPower * noiseScale1),0 ,1) * float4(_SSSColor,1.0f)  * input.irradiance  + float4(finalColor, 1.0f);
            
            //Light transparency
            t = tex2D(_DepthTextureBack, posinBackSpace.xy);
            dist = abs(posinBackSpace.z - t.r);
            float transparency = clamp( 1 - exp(-_Transparency * dist),0,1) ;


            //Transparency
            half4 baseColor = float4(col.rgb, 1) ;
            float4 offset = input.proj; // We shift our pixel to the desired position

            float4 tempCoord = UNITY_PROJ_COORD(offset);
            tempCoord.zw +=(input.normalColor.rg ) * _RefractivePower;
            tempCoord.xy +=(input.normalColor.rg ) * _RefractivePower;

            half4 col1 = tex2Dproj(_GrabTexture, tempCoord);

            col1.a = 1;
            baseColor = lerp (col1, baseColor, transparency);

            return baseColor;
         }
 
         ENDCG
      }
 
    }
 }
   Fallback "VertexLit"
}