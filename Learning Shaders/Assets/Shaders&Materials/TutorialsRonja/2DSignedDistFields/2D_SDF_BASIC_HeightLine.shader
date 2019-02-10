Shader "Tutorial/2D_SDF_BASIC_HeightLine"
{
	Properties
	{
		_InsideColor("Inside Color",Color) = (.5,0,0,1)
		_OutsideColor("Outside Color", Color) = (0,.5,0,1)
		_LineDistance("Line Distance",Range(0,2)) = 1
		_LineThickness("Line Thickness",Range(0,.1)) = 0.05
		_LineColor("Line Color",Color) = (0,0,0,1)
		[IntRange]_SubLines("Lines Between major one",Range(1,10)) = 4
		_SubLineThickness("Subline Thickness",Range(0,0.05)) = 0.01
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off

		Pass
		{

			CGPROGRAM
			#include "UnityCG.cginc"
			
			#pragma vertex vert
			#pragma fragment frag

			struct appdata{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 worldPos: TEXCOORD0;
			};

			float4 _InsideColor;
			float4 _OutsideColor;
			float _LineDistance;
			float _LineThickness;
			float4 _LineColor;
			float _SubLines;
			float _SubLineThickness;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);;
				return o;
			}

			float2 translate(float2 samplePos, float2 offset)
			{
				return samplePos - offset;
			}

			float2 rotate(float2 samplePos, float rotation)
			{
				const float PI = 3.14159274;
				float angle = rotation * PI * 2 - 1;
				float sine, cosine;
				sincos(angle, sine, cosine);
				return float2(cosine*samplePos.x + sine * samplePos.y, cosine*samplePos.y - sine * samplePos.x);
			}

			float2 scale(float2 samplePos, float scale)
			{
				return samplePos / scale;
			}

			float circle(float2 samplePos, float radius)
			{
				return length(samplePos)-radius;
			}

			float rectangle(float2 samplePos, float2 halfSize)
			{
				float2 compWiseEdgeDist = abs(samplePos) - halfSize;

				float outsideDist = length(max(compWiseEdgeDist, 0));
				float insideDist = min(max(compWiseEdgeDist.x, compWiseEdgeDist.y), 0);

				return outsideDist + insideDist;
			}

			float merge(float shape1, float shape2)
			{
				return min(shape1, shape2);
			}

			float intersect(float shap1, float shape2)
			{
				return max(shap1, shape2);
			}

			float subtract(float base, float substraction)
			{
				return intersect(base, -substraction);
			}

			float interpolate(float shape1, float shape2, float amount)
			{
				return lerp(shape1, shape2, amount);
			}

			float round_merge(float shape1, float shape2, float radius)
			{
				float2 intersectionSpace = float2(shape1 - radius, shape2-radius);
				intersectionSpace = min(intersectionSpace, 0);
				float insideDist = -length(intersectionSpace);
				float simpleUnion = merge(shape1, shape2);
				float outsideDist = max(simpleUnion, radius);
				return insideDist+outsideDist;
			}

			float round_intersect(float shape1, float shape2, float radius)
			{
				float2 intersectionSpace = float2(shape1 + radius, shape2 + radius);
				intersectionSpace = max(intersectionSpace, 0);
				float outsideDist = length(intersectionSpace);
				float simpleIntersection = intersect(shape1, shape2);
				float indsideDist = min(simpleIntersection, -radius);
				return outsideDist + indsideDist;
			}

			float round_subtract(float base, float substraction, float radius)
			{
				return round_intersect(base, -substraction, radius);
			}
			
			float champfer_merge(float shape1, float shape2, float champferSize)
			{
				const float SQRT_05 = 0.70710678118;
				float simpleMerge = merge(shape1, shape2);
				float champfer = (shape1 + shape2)*SQRT_05;
				champfer = champfer - champferSize;
				return merge(simpleMerge, champfer);
			}

			float champfer_intersect(float shape1, float shape2, float champferSize)
			{
				const float SQRT_05 = 0.70710678118;
				float simpleIntersect = intersect(shape1, shape2);
				float champfer = (shape1 + shape2)*SQRT_05;
				champfer += champferSize;
				return intersect(simpleIntersect, champfer);
			}

			float champfer_subtract(float base, float substraction, float champferSize)
			{
				return champfer_intersect(base, -substraction, champferSize);
			}

			float round_border(float shape1, float shape2, float radius)
			{
				float2 pos = float2(shape1, shape2);
				float distFromBorderIntersection = length(pos);
				return distFromBorderIntersection - radius;
			}

			float groove_border(float base,float groove,float width, float depth)
			{
				float circleBorder = abs(groove) - width;
				float grooveShape = subtract(circleBorder, base + depth);
				return subtract(base,grooveShape);
			}

			void mirror(inout float2 position)
			{
				position.x = abs(position.x);
			}

			float2 cells(inout float2 position, float2 period)
			{

				float2 cellIndex = position / period;
				cellIndex = floor(cellIndex);

				position = fmod(position, period);
				position += period;
				position = fmod(position, period);

				return cellIndex;
			}

			float radial_cells(inout float2 position, float cells,bool mirrorEverySecond = false)
			{
				float2 radialPos = float2(atan2(position.x, position.y), length(position));


				const float PI = 3.14159;
				float cellSize = PI * 2 / cells;

				float cellIndex = fmod(floor(radialPos.x / cellSize) + cells, cells);

				radialPos.x = fmod(fmod(radialPos.x, cellSize) + cellSize, cellSize);

				if(mirrorEverySecond)
				{
					float flip = fmod(cellIndex, 2);
					flip = abs(flip - 1);
					radialPos.x = lerp(cellSize - radialPos.x, radialPos.x, flip);
				}

				sincos(radialPos.x, position.x, position.y);
				position *= radialPos.y;

				return cellIndex;
			}

			void wobble(inout float2 position, float2 frequency,float2 amount)
			{
				float2 wobble = sin(position.yx * frequency) * amount;
				position = position + wobble;
			}

			float scene(float2 position)
			{
				const float PI = 3.14159;

				float frequency = 5;
				float offset = _Time.y;
				offset = fmod(offset, PI * 2 / frequency);
				position = translate(position, offset);
				wobble(position,5, .05);
				position = translate(position, -offset);
				
				float2 squarePosition = position;
				squarePosition = translate(squarePosition, float2(2, 2));
				squarePosition = rotate(squarePosition, .125);
				float squareShape = rectangle(squarePosition, float2(1, 1));

				float2 circlePosition = position;
				circlePosition = translate(circlePosition, float2(1, 1.5));
				float circleShape = circle(circlePosition, 1);

				float combination = merge(circleShape, squareShape);

				return combination;

			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float dist = scene(i.worldPos.xz);
				fixed4 col = lerp(_InsideColor, _OutsideColor, step(0, dist));
				
				float distChange = fwidth(dist) * .5;

				float majorLineDist = abs(frac(dist / _LineDistance + 0.5) - 0.5) * _LineDistance;
				float majorLines = smoothstep(_LineThickness - distChange, _LineThickness + distChange, majorLineDist);

				float distBetweenSubLine = _LineDistance / _SubLines;
				float subLineDist = abs(frac(dist / distBetweenSubLine + 0.5) - 0.5) * distBetweenSubLine;
				float subLines = smoothstep(_SubLineThickness - distChange, _SubLineThickness + distChange, subLineDist);


				return lerp(_LineColor, col,majorLines*subLines);
			}

			ENDCG
		}
	}
	FallBack "Standard"
}