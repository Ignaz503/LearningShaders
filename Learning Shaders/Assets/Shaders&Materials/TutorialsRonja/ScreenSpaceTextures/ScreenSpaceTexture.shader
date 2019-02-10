Shader "Tutorial/ScreenSpaceTexture"
{
	Properties
	{
		_Color("Color",Color) = (0,0,0,1)
		_MainTex("Texture",2D) = "while"{}
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
		}
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
				float4 screenPosition: TEXCOORD0;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPosition = ComputeScreenPos(o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float2 texCoord = i.screenPosition.xy / i.screenPosition.w;

				float aspectRatio = _ScreenParams.x / _ScreenParams.y;
				texCoord.x *= aspectRatio;

				texCoord = TRANSFORM_TEX(texCoord, _MainTex);

				fixed4 col = tex2D(_MainTex,texCoord);
				col *= _Color;
				return col;
			}

			ENDCG
		}
	}
}