// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "TexturedGradient" {
   Properties {
      _Texture ("Texture ", 2D) = "black" {}
   }
   SubShader { 
      Tags {"Queue"="Transparent" "RenderType" = "Transparent"}

      Pass {    
        Tags { "LightMode" = "ForwardBase" } 
         Blend SrcAlpha OneMinusSrcAlpha
         Cull Off
         ZTest LEqual
         ZWrite Off

         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
         #pragma multi_compile_fog
         #pragma multi_compile_fwdbase
         #pragma fragmentoption ARB_precision_hint_fastest


         #include "AutoLight.cginc"
         #include "UnityCG.cginc"
         uniform fixed4 _LightColor0; 


         uniform sampler2D _Texture;
         struct vertexOutput 
         {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
         };

 
         vertexOutput vert(appdata_full v) 
         {
            vertexOutput output;
            float4x4 modelMatrix = unity_ObjectToWorld;
            float4x4 modelMatrixInverse = unity_WorldToObject;
            float4 outpos = UnityObjectToClipPos(v.vertex);
            output.uv = v.texcoord.xy;
            output.pos = outpos;
            return output;
         }
 
         fixed4 frag(vertexOutput input) : COLOR
         {
            fixed4 tempcol = tex2D(_Texture,input.uv);
            fixed4 col = (tempcol.rgb, 1.0f);// - input.uv.y * 0.8f);
            return col;
         }
 
         ENDCG
      }
 
    }
 
   Fallback "VertexLit"
}