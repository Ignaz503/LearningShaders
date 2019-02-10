Shader "Tutorial/PostProcess/1DBoxBlurY"
{
	Properties
	{
		[HideInInspector]_MainTex("Texture",2D) = "while"{}
		_BlurSize("Blur Size",Range(0,0.1)) = 0
	    [KeywordEnum(Low,Medium,High)]_Samples("Sample amount",float) = 0
	}

	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		Pass
		{

			CGPROGRAM
			#include "UnityCG.cginc"
			
			#pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH
			#pragma vertex vert
			#pragma fragment frag


			#if _SAMPLES_LOW
				#define SAMPLES 10
			#elif _SAMPLES_MEDIUM
				#define SAMPLES 30
			#else
				#define SAMPLES 100
			#endif

			struct appdata{
				float4 vertex : POSITION;
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _BlurSize;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 col = 0;
				for(float index = 0; index < SAMPLES; index++)
				{
					float2 uv = i.uv + float2(0, (index / (SAMPLES-1) - 0.5) * _BlurSize);
					col+= tex2D(_MainTex,uv);
				}
				col /= SAMPLES;
				return col;
			}

			ENDCG
		}
	}
}