Shader "Tutorial/HeightLinePerlin"
{
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness",Range(0,1)) = .5
		_Metallic("Metalness",Range(0,1)) = .5
		[HDR] _Emission("Emission",Color) = (0,0,0,1)
		_CellSize("Cell Size",Range(0,1)) = 1 
		_ScrollSpeed("Scroll Speed",Range(0,1)) = 1
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
		float _CellSize;
		float _ScrollSpeed;

		float rand3Dto1D(float3 vec, float3 dotDir = float3(12.9898, 78.233, 37.719))
		{
			float3 smallVal = sin(vec);
			float random = dot(vec, dotDir);
			random = frac(sin(random) * 143758.5453);
			return random;
		}

		float rand2DTo1D(float2 value, float2 dotDir = float2(12.9898,78.233))
		{
			float2 smallValue = sin(value);
			float random = dot(smallValue, dotDir);
			random = frac(sin(random) * 143758.5453);
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
				rand2DTo1D(value, float2(12.989, 78.233)),
				rand2DTo1D(value, float2(39.346, 11.135))
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


		float rand4DTo1D(float4 vec, float4 dotDir = float4(12.9898, 78.233, 37.719, 25.632))
		{
			float4 smallVal = sin(vec);
			float random = dot(vec, dotDir);
			random = frac(sin(random) * 143758.5453);
			return random;
		}

		float4 rand4DTo4D(float4 value)
		{
			return float4(
				rand4DTo1D(value, float4(12.989, 78.233, 37.719, 20.615)),
				rand4DTo1D(value, float4(39.346, 11.135, 83.155, 38.774)),
				rand4DTo1D(value, float4(73.156, 52.235, 09.151, 7.786)),
				rand4DTo1D(value, float4(42.821, 16.968, 44.054, 90.853))
				);		
		}

		inline float easeIn(float interpolator)
		{
			return interpolator * interpolator;
		}

		float easeOut(float interpolator)
		{
			return 1 - easeIn(1 - interpolator);
		}

		float easeInOut(float interpolator)
		{
			float inE = easeIn(interpolator);
			float outE = easeOut(interpolator);
			return lerp(inE, outE, interpolator);
		}

		float valueNoise1D(float value)
		{
			float prevCellnoise = rand1DTo1D(floor(value));
			float nextCellnoise = rand1DTo1D(ceil(value));
			float interpolator = frac(value);
			interpolator = easeInOut(interpolator);
			return lerp(prevCellnoise, nextCellnoise, interpolator);
		}

		float valueNoise2D(float2 value)
		{
			float upperLeftCell = rand2DTo1D(float2(floor(value.x), ceil(value.y)));
			float upperRightCell = rand2DTo1D(float2(ceil(value.x), ceil(value.y)));
			float lowerLeftCell = rand2DTo1D(float2(floor(value.x), floor(value.y)));
			float lowerRightCell = rand2DTo1D(float2(ceil(value.x), floor(value.y)));
		
			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));

			float upperCells = lerp(upperLeftCell, upperRightCell, interpolatorX);
			float lowerCells = lerp(lowerLeftCell, lowerRightCell, interpolatorX);

			return lerp(lowerCells, upperCells, interpolatorY);
		}

		float valueNoise3DTo1D(float3 value)
		{
			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));
			float interpolatorZ = easeInOut(frac(value.z));

			float cellNoiseZ[2];
			[unroll]
			for (int z = 0; z <= 1; z++)
			{
				float cellNoiseY[2];
				[unroll]
				for (int y = 0; y <= 1; y++)
				{
					float cellNoiseX[2];
					[unroll]
					for (int x = 0; x <= 1; x++)
					{
						float3 cell = floor(value) + float3(x, y, z);
						cellNoiseX[x] = rand3Dto1D(cell);
					}
					cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
				}
				cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
			}
			float noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
			return noise;
		}

		float3 valueNoise3DTo3D(float3 value)
		{
			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));
			float interpolatorZ = easeInOut(frac(value.z));

			float3 cellNoiseZ[2];
			[unroll]
			for (int z = 0; z <= 1; z++)
			{
				float3 cellNoiseY[2];
				[unroll]
				for (int y = 0; y <= 1; y++)
				{
					float3 cellNoiseX[2];
					[unroll]
					for (int x = 0; x <= 1; x++)
					{
						float3 cell = floor(value) + float3(x, y, z);
						cellNoiseX[x] = rand3DTo3D(cell);
					}
					cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
				}
				cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
			}
			float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
			return noise;
		}

		float gradientNoise(float value)
		{
			float fraction = frac(value);
			float interpolator = easeInOut(fraction);

			float prevCellIncline = rand1DTo1D(floor(value)) * 2 - 1;
			float prevCellLinePoint = prevCellIncline * fraction;

			float nextCellIncline = rand1DTo1D(ceil(value)) * 2 - 1;
			float nextCellLinePoint = nextCellIncline * (fraction - 1);

			return lerp(prevCellLinePoint, nextCellLinePoint, interpolator);
		}

		float perlinNoise(float2 value)
		{
			float2 lowerLeftDirection = rand2DTo2D(float2(floor(value.x), floor(value.y))) * 2 - 1;
			float2 lowerRightDirection = rand2DTo2D(float2(ceil(value.x), floor(value.y))) * 2 - 1;
			float2 upperLeftDirection = rand2DTo2D(float2(floor(value.x), ceil(value.y))) * 2 - 1;
			float2 upperRightDirection = rand2DTo2D(float2(ceil(value.x), ceil(value.y))) * 2 - 1;

			float2 fraction = frac(value);

			//get values of cells based on fraction and cell directions
			float lowerLeftFunctionValue = dot(lowerLeftDirection, fraction - float2(0, 0));
			float lowerRightFunctionValue = dot(lowerRightDirection, fraction - float2(1, 0));
			float upperLeftFunctionValue = dot(upperLeftDirection, fraction - float2(0, 1));
			float upperRightFunctionValue = dot(upperRightDirection, fraction - float2(1, 1));

			float interpolatorX = easeInOut(fraction.x);
			float interpolatorY = easeInOut(fraction.y);

			//interpolate between values
			float lowerCells = lerp(lowerLeftFunctionValue, lowerRightFunctionValue, interpolatorX);
			float upperCells = lerp(upperLeftFunctionValue, upperRightFunctionValue, interpolatorX);

			float noise = lerp(lowerCells, upperCells, interpolatorY);
			return noise;
		}

		float perlinNoise(float3 value)
		{
			float3 fraction = frac(value);
			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));
			float interpolatorZ = easeInOut(frac(value.z));

			float3 cellNoiseZ[2];
			[unroll]
			for (int z = 0; z <= 1; z++)
			{
				float3 cellNoiseY[2];
				[unroll]
				for (int y = 0; y <= 1; y++)
				{
					float3 cellNoiseX[2];
					[unroll]
					for (int x = 0; x <= 1; x++)
					{
						float3 cell = floor(value) + float3(x, y, z);
						float3 cellDir = rand3DTo3D(cell) * 2 - 1;
						float3 compareVector = fraction - float3(x, y, z);
						cellNoiseX[x] = dot(cellDir, compareVector);
					}
					cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
				}
				cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
			}
			float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
			return noise;
		}

		float perlinNoise(float4 value)
		{
			float4 fraction = frac(value);
			float interpolatorX = easeInOut(frac(value.x));
			float interpolatorY = easeInOut(frac(value.y));
			float interpolatorZ = easeInOut(frac(value.z));
			float interpolatorW = easeInOut(frac(value.w));

			float4 cellNoiseW[2];
			[unroll]
			for (int w = 0; w <= 1; w++)
			{
				float4 cellNoiseZ[2];
				[unroll]
				for (int z = 0; z <= 1; z++)
				{
					float4 cellNoiseY[2];
					[unroll]
					for (int y = 0; y <= 1; y++)
					{
						float4 cellNoiseX[2];
						[unroll]
						for (int x = 0; x <= 1; x++)
						{
							float4 cell = floor(value) + float4(x, y, z,w);
							float4 cellDir = rand4DTo4D(cell) * 2 - 1;
							float4 compareVector = fraction - float4(x, y, z,w);
							cellNoiseX[x] = dot(cellDir, compareVector);
						}
						cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
					}
					cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
				}
				cellNoiseW[w] = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
			}
			float4 noise = lerp(cellNoiseW[0], cellNoiseW[1], interpolatorW);
			return noise;
		}

		void surf(Input i, inout SurfaceOutputStandard o)
		{
			float3 value = i.worldPos.xyz / _CellSize;
			float4 valT = float4(value, _Time.y * _ScrollSpeed);

			float3 noise = perlinNoise(valT) + 0.5;

			noise = frac(noise * 6);

			float pixelNoiseChange = fwidth(noise);

			float heightline = smoothstep(1-pixelNoiseChange, 1, noise);
			heightline += smoothstep(pixelNoiseChange, 0, noise);

			o.Albedo = heightline;
		}
		ENDCG
	}
	FallBack "Standard"
}


