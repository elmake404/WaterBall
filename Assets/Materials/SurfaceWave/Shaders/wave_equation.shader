Shader "Custom/wave_equation" {
    Properties {
        [NoScaleOffset] _MainTex ("Input", 2D) = "black" {}
        [NoScaleOffset] _PrevTex ("Prev", 2D) = "black" {}
        [NoScaleOffset] _PrevPrevTex ("PrevPrev", 2D) = "black" {}
        _Param("Factor", Vector) = (0.1, 0.975, 0, 0)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        ZTest Always
        Cull Off
        ZWrite Off
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			sampler2D _PrevTex;
			sampler2D _PrevPrevTex;
            float4 _Param;  // [wave_c factor, decay factor, 0, 0]
            float2 _Stride;
            float _RoundAdjuster;
            
            v2f vert (appdata_img  v) {
                v2f o;
                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, v.texcoord.xy);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
				half prev = tex2D(_PrevTex, i.uv).r * 2 - 1;
				half prevL = tex2D(_PrevTex, half2(i.uv.x - _Stride.x, i.uv.y)).r * 2 - 1;
				half prevR = tex2D(_PrevTex, half2(i.uv.x + _Stride.x, i.uv.y)).r * 2 - 1;
				half prevT = tex2D(_PrevTex, half2(i.uv.x, i.uv.y + _Stride.y)).r * 2 - 1;
				half prevB = tex2D(_PrevTex, half2(i.uv.x, i.uv.y - _Stride.y)).r * 2 - 1;
				half value = prev * 2 + (prevL + prevR + prevT + prevB - prev * 4) * _Param.x - (tex2D(_PrevPrevTex, i.uv).r * 2 - 1);

				value += tex2D(_MainTex, i.uv).r * 2 - 1;
				value *= _Param.y;
				value = (value + 1) * 0.5;
                value += _RoundAdjuster;
				return fixed4(value, value, value, 1);
            }
            ENDCG
        }
    }
}
