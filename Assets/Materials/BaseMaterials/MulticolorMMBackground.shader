// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CustomMaterialBackgroundMM" {
   Properties {
      _CenterColor("Center Color", Color) = (1,1,1,1) 
      _MidColor ("Mid Color", Color) = (1,1,1,1) 
      _BackgroundColor ("Back Color", Color) = (1,1,1,1) 
      _Scale ("Global Scale", Float) = 1
      _Scale1 ("Scale Center Mid", Float) = 1
      _Scale2 ("Scale Mid Back", Float) = 1
      _OffsetVertical ("Vertical Offset", Float) = 0
   }
   SubShader {
    Tags {"Queue"="Transparent" "RenderType" = "Transparent"} 
    Pass {   

         Tags {"LightMode" = "ForwardBase" } 
         ZTest Always
         ZWrite Off
         Blend SrcAlpha OneMinusSrcAlpha
         CGPROGRAM
 
         #pragma vertex vert approxview
         #pragma fragment frag 
         #pragma multi_compile_fog
         #pragma multi_compile_fwdbase
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma fragmentoption ARB_fog_linear



         #include "AutoLight.cginc"
         #include "UnityCG.cginc"
         uniform half4 _CenterColor; 
         uniform half4 _BackgroundColor; 
         uniform half4 _MidColor; 
         uniform half _Scale;
         uniform half _Scale1;
         uniform half _Scale2;
         uniform half _OffsetVertical;

         struct vertexOutput 
         {
            half4 ColorFactor:FLOAT;
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


            output.pos = outpos;
            output.uv = v.texcoord.xy;
            TRANSFER_VERTEX_TO_FRAGMENT(output);


            return output;
         }
 
         half4 frag(vertexOutput input) : COLOR
         {
            half ColorFactorX = input.uv.x - 0.5;
            half ColorFactorY = max(input.uv.y + _OffsetVertical,0);
            half factor = (ColorFactorX * ColorFactorX + ColorFactorY * ColorFactorY);

            half factorStep = clamp(floor(factor*_Scale  + 0.5),0,1);
            half factorSoft = factor ;
            half4 tempcolshadowmid = lerp(_MidColor,_CenterColor, clamp((0.5f - factorSoft)* _Scale1 * 2.0f, 0, 1));
            half4 tempcolmidlight = lerp(_MidColor,_BackgroundColor,clamp((factorSoft - 0.5) * 2.0f* _Scale2,0,1));
            half4 tempcol = tempcolshadowmid * (1 - factorStep) + tempcolmidlight * factorStep;
            //half4 col = half4((factorSoft - 1.0)* _Scale2,(factorSoft - 1.0)* _Scale2,(factorSoft - 1.0)* _Scale2, 1.0);
            half4 col = tempcol;

            return col;
         }
 
         ENDCG
      }
 
    }
 
   Fallback "VertexLit"
}