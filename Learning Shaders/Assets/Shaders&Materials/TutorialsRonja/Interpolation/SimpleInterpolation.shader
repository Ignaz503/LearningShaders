Shader "Tutorial/SimpleInterpolation"
{
	Properties
	{
		_Color("Color",Color) = (0,0,0,1)
		_SecondaryColor("Secondary Color", Color) = (1,1,1,1)
		_Blend("Blend Value", Range(0,1)) = 0
		_MainTex("Texture",2D) = "white"{}
		_SecondaryTex("Second Texture",2D) = "white" {}
		_TextureBlend("Texture Blend Value", Range(0,1)) = 0
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

			fixed4 _Color;
			fixed4 _SecondaryColor;
			float _Blend;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _SecondaryTex;
			float4 _SecondaryTex_ST;
			float _TextureBlend;

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

				fixed4 mainCol = tex2D(_MainTex, mainUV);
				fixed4 secondaryCol = tex2D(_SecondaryTex, secondaryUV);

				fixed4 col = lerp(mainCol, secondaryCol, _TextureBlend);

				col *= lerp(_Color,_SecondaryColor,_Blend);
				return col;
			}

			ENDCG
		}
	}
}