Shader "Tutorial/2D_SDF_BASIC_HardEdge"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)

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

			fixed3 _Color;
			//sampler2D _MainTex;
			//float4 _MainTex_ST;

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

			float scene(float2 position)
			{
				float2 pos = position;
				pos = translate(pos, float2(2, 0));
				pos = rotate(pos, _Time.y*.1);
				float pulseScale = 1;
				pos = scale(pos, pulseScale);
				float sceneDist = rectangle(pos, float2(1, 3)) * pulseScale;
				return sceneDist;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float dist = scene(i.worldPos.xz);
				
				float distChange = fwidth(dist)*0.5;
					
				float antiAliasedCutoff = smoothstep(distChange, -distChange, dist);
				fixed4 col = fixed4(_Color, antiAliasedCutoff);

				return col;
			}

			ENDCG
		}
	}
	FallBack "Standard"
}