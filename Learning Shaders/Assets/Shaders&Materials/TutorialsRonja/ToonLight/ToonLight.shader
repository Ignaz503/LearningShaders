Shader "Tutorial/ToonLight"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		[HDR] _Emission("Emission",Color) = (0,0,0,1)

		[Header(Lighting Parameters)]
		_ShadowTint("Shadow Tint", Color) = (0,0,0,1)
		[IntRange] _StepAmount("Shdaow Steps",Range(1,16)) = 2
		_StepWidth("Step Size",Range(0.05,1)) = 0.25
		_SpecularSize("Specular Size",Range(0,1)) = 0.1
		_SpecularFalloff("Specular Falloff",Range(0,2)) = 1
		_SpecularColor("Specular Color",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Stepped fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0


        struct Input
        {
            float2 uv_MainTex;
        };


		struct ToonSurfaceOutput
		{
			fixed3 Albedo;
			half3 Emission;
			fixed3 Specular;
			fixed Alpha;
			fixed3 Normal;
		};

        sampler2D _MainTex;
        fixed4 _Color;
		half3 _Emission; 
		float3 _ShadowTint;
		float _StepAmount;
		float _StepWidth;
		float _SpecularSize;
		float _SpecularFalloff;
		fixed3 _SpecularColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout ToonSurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
			fixed4 col = tex2D(_MainTex, IN.uv_MainTex);
			col *=_Color;
            o.Albedo = col.rgb;
			o.Specular = _SpecularColor;

			float3 shadowCol = col.rgb * _ShadowTint;

			o.Emission = _Emission + shadowCol;
        }

		float4 LightingStepped(ToonSurfaceOutput s, float3 lightDir, half3 viewDir, float shadowAttenuation)
		{
			float towardsLight = dot(s.Normal, lightDir);
			towardsLight /= _StepWidth;
			//float towradsLightChange = fwidth(towardsLight);
			float lightIntensity = floor(towardsLight);
			
			float change = fwidth(towardsLight);
			float smoothing = smoothstep(0, change, frac(towardsLight));
			lightIntensity += smoothing;
			
			lightIntensity /= _StepAmount;
			lightIntensity = saturate(lightIntensity);

		#ifdef USING_DIRECTIONAL_LIGHT
			float shadowAttenChange = fwidth(shadowAttenuation)*.5f;
			float shadow = smoothstep(0.5-shadowAttenChange, 0.5+shadowAttenChange, shadowAttenuation);
		#else
			float shadowAttenChange = fwidth(shadowAttenuation);
			float shadow = smoothstep(0, shadowAttenChange, shadowAttenuation);
		#endif
			
			lightIntensity *= shadow;

			float3 reflectionDir = reflect(lightDir, s.Normal);
			float towardsReflection = dot(viewDir, -reflectionDir);
			float specFO = dot(viewDir, s.Normal);
			specFO = pow(specFO, _SpecularFalloff);
			towardsReflection *= specFO;

			float specularChange = fwidth(towardsReflection);
			float specularIntensity = smoothstep(1 - _SpecularSize, 1 - _SpecularSize + specularChange, towardsReflection);
			
			specularIntensity *= shadow;

			float3 shadowCol = s.Albedo*_ShadowTint;

			float4 col;
			col.rgb = s.Albedo * lightIntensity *_LightColor0.rgb;
			col.rgb = lerp(col.rgb, s.Specular*_LightColor0.rgb, saturate(specularIntensity));
			col.a = s.Alpha;

			return col;
		}

        ENDCG
    }
    FallBack "Diffuse"
}
