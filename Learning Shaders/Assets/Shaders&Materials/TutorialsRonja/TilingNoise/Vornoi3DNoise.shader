Shader "Tutorial/Vornoi3DNoise"
{
	Properties{
		_CellAmount("Cell Amount",Range(1,32)) = 2
		_Period("Repeat every X Cells",Vector) = (4,4,0,0)
		_Height("Z Coord(height)",Range(0,1)) = 0
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
			float3 _Period;
			float _Height;

			float3 modulo(float3 divident, float3 divisor)
			{
				float3 posDiv = divident % divisor + divisor;
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

			float3 vornoiNoise(float2 value)
			{
				float2 baseCell = floor(value);

				float minDistToCell = 100;
				float2 closestCell = baseCell;
				float2 toClosestCell;

				[unroll]
				for (int x1 = -1; x1 <= 1; x1++)
				{
					[unroll]
					for (int y1 = -1; y1 <= 1; y1++)
					{
						float2 cell = baseCell + float2(x1, y1);
						float2 cellPosition = cell + rand2DTo2D(cell);
						float2 toCell = cellPosition - value;
						float distToCell = length(toCell);
						if (distToCell < minDistToCell)
						{
							minDistToCell = distToCell;
							closestCell = cell;
							toClosestCell = toCell;
						}
					}
				}

				float minEedgeDistance = 10;
				[unroll]
				for (int x2 = -1; x2 <= 1; x2++)
				{
					[unroll]
					for (int y2 = -1; y2 <= 1; y2++)
					{
						float2 cell = baseCell + float2(x2, y2);
						float2 cellPosition = cell + rand2DTo2D(cell);
						float2 toCell = cellPosition - value;

						float2 diffToClosesCell = abs(closestCell - cell);
						bool isClosest = diffToClosesCell.x + diffToClosesCell.y < 0.1;
						if (!isClosest)
						{
							float2 toCenter = (toClosestCell + toCell) *0.5;
							float2 cellDiff = normalize(toCell - toClosestCell);
							float edgeDistance = dot(toCenter, cellDiff);
							minEedgeDistance = min(minEedgeDistance, edgeDistance);
						}

					}
				}

				float random = rand2DTo1D(closestCell);
				return float3(minDistToCell, random, minEedgeDistance);
			}

			float3 vornoiNoise(float3 value,float3 period)
			{
				float3 baseCell = floor(value);

				float minDistToCell = 100;
				float3 closestCell = baseCell;
				float3 toClosestCell;

				[unroll]
				for (int x1 = -1; x1 <= 1; x1++)
				{
					[unroll]
					for (int y1 = -1; y1 <= 1; y1++)
					{
						[unroll]
						for (int z1 = -1; z1 <= 1; z1++)
						{
							float3 cell = baseCell + float3(x1, y1, z1);
							float3 tiledCell = modulo(cell, period);
							float3 cellPosition = cell + rand3DTo3D(tiledCell);
							float3 toCell = cellPosition - value;
							float distToCell = length(toCell);
							if (distToCell < minDistToCell)
							{
								minDistToCell = distToCell;
								closestCell = cell;
								toClosestCell = toCell;
							}
						}
					}
				}

				float minEedgeDistance = 10;
				[unroll]
				for (int x2 = -1; x2 <= 1; x2++)
				{
					[unroll]
					for (int y2 = -1; y2 <= 1; y2++)
					{
						[unroll]
						for (int z2 = -1; z2 <= 1; z2++)
						{
							float3 cell = baseCell + float3(x2, y2, z2);
							float3 tiledCell = modulo(cell, period);
							float3 cellPosition = cell + rand3DTo3D(tiledCell);
							float3 toCell = cellPosition - value;

							float3 diffToClosesCell = abs(closestCell - cell);
							bool isClosest = diffToClosesCell.x + diffToClosesCell.y + diffToClosesCell.z < 0.1;
							if (!isClosest)
							{
								float3 toCenter = (toClosestCell + toCell) *0.5;
								float3 cellDiff = normalize(toCell - toClosestCell);
								float edgeDistance = dot(toCenter, cellDiff);
								minEedgeDistance = min(minEedgeDistance, edgeDistance);
							}
						}
					}
				}

				float random = rand3Dto1D(closestCell);
				return float3(minDistToCell, random, minEedgeDistance);
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
				float3 value = float3(i.uv,_Height) * _CellAmount;
				float noise = vornoiNoise(value,_Period).z;
				return noise;
			}

			ENDCG
		}
	}
	FallBack "Standard"
}


