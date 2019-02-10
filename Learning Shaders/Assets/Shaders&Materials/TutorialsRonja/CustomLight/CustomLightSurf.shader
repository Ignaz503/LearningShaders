Shader "Tutorial/CustomLightSurf"
{
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		//[HDR] _Emission("Emission",Color) = (0,0,0,1)
		_Ramp("Toon Ramp",2D) = "white"{}
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		CGPROGRAM

		#pragma surface surf Custom fullforwardshadows
		#pragma target 3.0
			
		struct Input
		{
			float2 uv_MainTex;
		};
			
		sampler2D _MainTex;
		sampler2D _Ramp;

		fixed4 _Color;
		//half3 _Emission;

		float4 LightingCustom(SurfaceOutput s, float3 lightDir, float atten)
		{
			float towardsLight = dot(s.Normal, lightDir);

			towardsLight = towardsLight * .5 + .5;

			float3 lightIntensity = tex2D(_Ramp, towardsLight).rgb;

			float4 col;
			col.rgb = lightIntensity * s.Albedo * atten * _LightColor0.rgb;
			col.a = s.Alpha;

			return col;
		}

		void surf(Input i, inout SurfaceOutput o)
		{
			fixed4 col = tex2D(_MainTex, i.uv_MainTex);
			col *= _Color;
			o.Albedo = col.rgb;
			//o.Emission = _Emission;
		}
		ENDCG
	}
	FallBack "Standard"
}


