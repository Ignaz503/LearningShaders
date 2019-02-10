Shader "Tutorial/VertTiledNoise"
{
	Properties{
		_CellAmount("Cell Amount",Range(1,32)) = 2
		[IntRange]_Roughness("Roughness",Range(1,8)) = 3
		_Persistence("Persistence",Range(0,1)) = .4
		_Period("Repeat every X Cells",Vector) = (4,4,0,0)
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}
		Pass{
			CGPROGRAM

			#include "UnityCG.cginc"

			#pragma vertex vert 
			#pragma fragment frag
			#pragma target 3.0
			
			#define OCTAVES 4

			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			float _CellAmount;
			float _Roughness;
			float _Persistence;
			float2 _Period;

			float2 modulo(float2 divident, float2 divisor)
			{
				float2 posDiv = divident % divisor + divisor;
				return posDiv % divisor;
			}

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

			float sampleLayeredNoise(float value)
			{
				float noise = 0;
				float frequency = 1;
				float factor = 1;
				[unroll]
				for (int  i = 0; i < OCTAVES; i++)
				{
					noise = noise + gradientNoise(value*frequency + i * 0.72354)*factor;
					factor *= _Persistence;
					frequency *= _Roughness;
				}
				return noise;
			}

			float sampleLayeredNoise(float2 value)
			{
				float noise = 0;
				float frequency = 1;
				float factor = 1;
				[unroll]
				for (int i = 0; i < OCTAVES; i++)
				{
					noise = noise + perlinNoise(value*frequency + i * 0.72354)*factor;
					factor *= _Persistence;
					frequency *= _Roughness;
				}
				return noise;
			}

			float sampleLayeredNoise(float3 value)
			{
				float noise = 0;
				float frequency = 1;
				float factor = 1;
				[unroll]
				for (int i = 0; i < OCTAVES; i++)
				{
					noise = noise + perlinNoise(value*frequency + i * 0.72354)*factor;
					factor *= _Persistence;
					frequency *= _Roughness;
				}
				return noise;
			}

			float perlinNoise(float2 value, float2 period)
			{
				float2 cellsMinimum = floor(value);
				float2 cellsMaximum = ceil(value);

				cellsMinimum = modulo(cellsMinimum, period);
				cellsMaximum = modulo(cellsMaximum, period);

				float2 lowerLeftDirection = rand2DTo2D(float2(cellsMinimum.x, cellsMinimum.y)) * 2 - 1;
				float2 lowerRightDirection = rand2DTo2D(float2(cellsMaximum.x, cellsMinimum.y)) * 2 - 1;
				float2 upperLeftDirection = rand2DTo2D(float2(cellsMinimum.x, cellsMaximum.y)) * 2 - 1;
				float2 upperRightDirection = rand2DTo2D(float2(cellsMaximum.x, cellsMaximum.y)) * 2 - 1;
			
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

			float sampleLayerdTiledNoise(float2 value,float2 period)
			{
				float noise = 0;
				float frequency = 1;
				float factor = 1;
				[unroll]
				for (int i = 0; i < OCTAVES; i++)
				{
					noise = noise + perlinNoise(value*frequency + i * 0.72354,period*frequency)*factor;
					factor *= _Persistence;
					frequency *= _Roughness;
				}
				return noise;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_TARGET
			{
				float2 value = i.uv * _CellAmount;
				float noise = sampleLayerdTiledNoise(value, _Period) + 0.5;
				return noise;
			}

			ENDCG
		}
	}
	FallBack "Standard"
}


