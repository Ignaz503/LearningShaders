Shader "Tutorial/TextureInterpolation"
{
	Properties
	{
		_MainTex("Texture",2D) = "white"{}
		_SecondaryTex("Second Texture",2D) = "black" {}
		_BlendTexture("Texture Blend", 2D) = "grey"{}
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
				float4 position : SV_POSITION;
				float2 uv: TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _SecondaryTex;
			float4 _SecondaryTex_ST;

			sampler2D _BlendTexture;
			float4 _BlendTexture_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float2 mainUV = TRANSFORM_TEX(i.uv,_MainTex);
				float2 secondaryUV = TRANSFORM_TEX(i.uv, _SecondaryTex);
				float2 blendUV = TRANSFORM_TEX(i.uv, _BlendTexture);

				fixed4 mainCol = tex2D(_MainTex, mainUV);
				fixed4 secondaryCol = tex2D(_SecondaryTex, secondaryUV);
				fixed4 blendCol = tex2D(_BlendTexture, blendUV);

				float lerpVal = blendCol.r;

				fixed4 col = lerp(mainCol, secondaryCol, lerpVal);

				return col;
			}

			ENDCG
		}
	}
}