Shader "Tutorial/PostProcess/SweepingWave"
{
	Properties
	{
		[HideInInspector]_MainTex("Texture",2D) = "while"{}
		[Header(Wave)]
		_WaveDistance("Distance from player",float) = 10
		_WaveTrail("Length of the trail", Range(0,5)) = 1
		_WaveColor("Color",Color) = (1,0,0,1)
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
			
			#pragma vertex vert
			#pragma fragment frag

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
			sampler2D _CameraDepthTexture;

			float _WaveDistance;
			float _WaveTrail;
			float4 _WaveColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float depth = tex2D(_CameraDepthTexture, i.uv).r;
				depth = Linear01Depth(depth);
				depth = depth * _ProjectionParams.z;

				fixed4 source = tex2D(_MainTex, i.uv);

				if (depth >= _ProjectionParams.z)
					return source;

				float waveFront = step(depth, _WaveDistance);

				float waveTrial = smoothstep(_WaveDistance-_WaveTrail, _WaveDistance, depth);

				float wave = waveFront * waveTrial;


				fixed4 col = lerp(source, _WaveColor, wave);
				return col;
			}

			ENDCG
		}
	}
}