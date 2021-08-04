// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/wave_surface" {
	Properties {
		_Color ("Color", Color) = (1, 1, 1, 1)
		[HideInInspector] [NoScaleOffset] _WaveTex ("Wave", 2D) = "black" {}
        _Param("Factor", Vector) = (1, 1, 0, 0)
		_Specular("Specular", Float) = 10
	}
	SubShader {
		//Tags { "RenderType"="Opaque" }
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 200

		GrabPass{"_MyGrabTexture"}

		CGPROGRAM
		#pragma surface surf StandardSpecular alpha vertex:vert


		struct Input {
			float4 grabUV;
			float2 heightDisplace;
		};


		sampler2D _WaveTex;
        float4 _Color;
        float4 _Param;  // [height factor, normal factor, 0, 0]
        float2 _Stride;
		half _Specular;
		sampler2D _MyGrabTexture;
		sampler2D _CameraDepthTexture;

        void vert (inout appdata_full v, out Input o) {

			float4 hpos = UnityObjectToClipPos (v.vertex);
			o.grabUV = ComputeGrabScreenPos(hpos);
			o.heightDisplace = float2(1, 1);

			float surfaceDir = dot(float3(0, 1, 0), v.normal);
			if(surfaceDir < 1.0){return;}

            float2 uv = v.texcoord.xy;
            float height = tex2Dlod (_WaveTex, float4(uv, 0, 0)).r * 2 - 1;
            v.vertex.xyz += v.normal * height * _Param.x;

			hpos = UnityObjectToClipPos (v.vertex);
			o.grabUV = ComputeGrabScreenPos(hpos);
			

            float up    = tex2Dlod(_WaveTex, float4(uv.x, uv.y + _Stride.y, 0, 0)).r * 2 - 1;
            float down  = tex2Dlod(_WaveTex, float4(uv.x, uv.y - _Stride.y, 0, 0)).r * 2 - 1;
            float left  = tex2Dlod(_WaveTex, float4(uv.x - _Stride.x, uv.y, 0, 0)).r * 2 - 1;
            float right = tex2Dlod(_WaveTex, float4(uv.x + _Stride.x, uv.y, 0, 0)).r * 2 - 1;
            float nx = left - right;
            float ny = down - up;
			o.heightDisplace = float2(1 - nx/4, 1 - ny/4);
            v.normal = normalize(float3(nx, ny, -_Param.y));
            v.tangent = normalize(float4(_Param.y, ny, nx, -1));
			
        }


		void surf (Input IN, inout SurfaceOutputStandardSpecular o ) {
			o.Albedo = tex2Dproj(_MyGrabTexture, UNITY_PROJ_COORD(IN.grabUV) * (float4(IN.heightDisplace, 1, 1))) * _Color;
			fixed3 specularCol = fixed3((1 - IN.heightDisplace.x) * _Specular, (1 - IN.heightDisplace.y) * _Specular, 0);
			float gray = dot(specularCol, float3(0.299, 0.587, 0.114));
			o.Specular = fixed3(gray, gray, gray);
			o.Alpha = 1;
		}
		ENDCG
	}
}
