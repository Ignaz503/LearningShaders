Shader "Tutorial/WhiteNoiseTut"
{
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness",Range(0,1)) = .5
		_Metallic("Metalness",Range(0,1)) = .5
		[HDR] _Emission("Emission",Color) = (0,0,0,1)
		_CellSize("Cell Size",Vector) = (1,1,1,0)
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
			
		struct Input
		{
			float3 worldPos;
		};
			
		sampler2D _MainTex;
		fixed4 _Color;
		half _Smoothness;
		half _Metallic;
		half3 _Emission;
		float3 _CellSize;

		float rand3Dto1D(float3 vec, float3 dotDir = float3(12.9898, 78.233, 37.719))
		{
			float3 smallVal = sin(vec);
			float random = dot(vec, dotDir);
			random = frac(sin(random) * 143758.5453);
			return random;
		}

		float rand2DTo1D(float2 value, float2 dotDir = float2(12.9898,78.233))
		{
			float2 small = sin(value);
			float random = dot(small, dotDir);
			random = frac(sin(random)*143758.5453);
			return random;
		}

		float rand1DTo1D(float value, float mutator = 0.546)
		{
			float random = frac(sin(value + mutator)*143758.5453);
			return random;
		}

		float2 rand3DTo2D(float3 value)
		{
			return float2(
					rand3Dto1D(value, float3(12.989, 78.233, 37.719)),
					rand3Dto1D(value, float3(39.346, 11.135, 83.155))
				);
		}

		float2 rand2DTo2D(float2 value)
		{
			return float2(
					rand2DTo1D(value,float2(12.989,78.233)),
					rand2DTo1D(value,float2(39.346,11.135))
				);
		}

		float2 rand1DTo2D(float value)
		{
			return float2(
					rand1DTo1D(value, 3.9812),
					rand1DTo1D(value, 7.1536)
				);
		}

		float3 rand3DTo3D(float3 value)
		{
			return float3(
				rand3Dto1D(value, float3(12.989, 78.233, 37.719)),
				rand3Dto1D(value, float3(39.346, 11.135, 83.155)),
				rand3Dto1D(value, float3(73.156, 52.235, 09.151))
				);
		}

		float3 rand2DTo3D(float2 value)
		{
			return float3(
				rand2DTo1D(value, float2(12.989, 78.233)),
				rand2DTo1D(value, float2(39.346, 11.135)),
				rand2DTo1D(value, float2(73.156, 52.235))
				);
		}

		float3 rand1DTo3D(float value)
		{
			return float3(
				rand1DTo1D(value, 3.9812),
				rand1DTo1D(value, 7.1536),
				rand1DTo1D(value, 5.7241)
				);
		}

		void surf(Input i, inout SurfaceOutputStandard o)
		{
			float3 value = floor(i.worldPos / _CellSize);
			o.Albedo = rand3DTo3D(value);
		}
		ENDCG
	}
	FallBack "Standard"
}


