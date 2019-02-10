Shader "Tutorial/RiverShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		[Header(Spec Layer 1)]
		_Specs1("Specs", 2D) = "white"{}
		_SpecColor1("Spec Color", Color) = (1,1,1,1)
		_SpecDirection1("Spec Direction", Vector) = (0,1,0,0)
		_TimeScale1("Time Scale Spec 1",Range(0,2)) = 1
		[Header(Spec Layer2)]
		_Specs2("Specs", 2D) = "white"{}
		_SpecColor2("Spec Color", Color) = (1,1,1,1)
		_SpecDirection2("Spec Direction", Vector) = (0,1,0,0)
		_TimeScale2("Time Scale Spec 2",Range(0,2)) = 1
		[Header(Foam)]
		_FoamNoise("Foam Noise",2D) = "white"{}
		_FoamDirection("Foam Direction",Vector) = (0,1,0,0)
		_FoamColor("Foam Color", Color) = (1,1,1,1)
		_FoamAmount("Foam Amount", Range(0,2)) = 1
		_TimeScaleFoam("Foam Change Time Scale",Range(0,2)) = 1
	}
		SubShader
		{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"ForceNoShadowCasting" = "True"
		}
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert fullforwardshadows alpha

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 4.0

		sampler2D_float _CameraDepthTexture;

        struct Input
        {
            float2 uv_Specs1;
			float2 uv_Specs2;
			float2 uv_Foam;
			float eyeDepth;
			float4 screenPos;
        };

        fixed4 _Color;

		sampler2D _Specs1;
		fixed4 _SpecColor1;
		float2 _SpecDirection1;
		float _TimeScale1;

		sampler2D _Specs2;
		fixed4 _SpecColor2;
		float2 _SpecDirection2;
		float _TimeScale2;

		sampler2D _FoamNoise;
		float2 _FoamDirection;
		fixed4 _FoamColor;
		float _FoamAmount;
		float _TimeScaleFoam;

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			COMPUTE_EYEDEPTH(o.eyeDepth);
		}


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

		fixed4 ApplySpecLayer(float2 uv, float2 scrollDir, float timeScale, sampler2D sampleTex, fixed4 layerColor, fixed4 currentCol)
		{
			float2 specCoordinates = uv + scrollDir * (_Time.y * timeScale);
			fixed4 col = tex2D(sampleTex, specCoordinates)*layerColor;
			currentCol.rgb = lerp(currentCol.rgb, col.rgb, col.a);
			currentCol.a = lerp(currentCol.a, 1, col.a);
			return currentCol;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			float4 col = _Color;

			//float2 specCoordinates1 = IN.uv_Specs1 + _SpecDirection1 * (_Time.y * _TimeScale1);
			//fixed4 specLayer1 = tex2D(_Specs1, specCoordinates1)*_SpecColor1;
			//col.rgb = lerp(col.rgb, specLayer1.rgb, specLayer1.a);
			//col.a = lerp(col.a, 1, specLayer1.a);

			col = ApplySpecLayer(IN.uv_Specs1, _SpecDirection1, _TimeScale1, _Specs1, _SpecColor1, col);


			//float2 specCoordinates2 = IN.uv_Specs2 + _SpecDirection2 * (_Time.y * _TimeScale2);
			//fixed4 specLayer2 = tex2D(_Specs2, specCoordinates2)* _SpecColor2;
			//col.rgb = lerp(col.rgb, specLayer2.rgb, specLayer2.a);
			//col.a = lerp(col.a, 1, specLayer2.a);

			col = ApplySpecLayer(IN.uv_Specs2, _SpecDirection2, _TimeScale2, _Specs2, _SpecColor2, col);

			//foam
			float4 projCoords = UNITY_PROJ_COORD(IN.screenPos);
			float rawZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, projCoords);
			float sceneZ = LinearEyeDepth(rawZ);
			float surfaceZ = IN.eyeDepth;

			float2 foamCoord = IN.uv_Foam + _FoamDirection * (_Time.y*_TimeScaleFoam);
			float2 foamNoise = tex2D(_FoamNoise, foamCoord).r;

			float foam = 1 - ((sceneZ - surfaceZ) / _FoamAmount);
			foam = saturate(foam -  foamNoise);

			col.rgb = lerp(col.rgb, _FoamColor.rgb, foam);
			col.a = lerp(col.a, 1, foam*_FoamColor.a);

			o.Albedo = col.rgb;
			o.Alpha = col.a;
			//o.Albedo = foam;
			//o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
