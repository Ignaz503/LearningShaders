Shader "Tutorial/HullOutline"
{
	Properties
	{
		_Tint("Tint",Color) = (0,0,0,1)
		_MainTex("Texture",2D) = "white"{}
		
		[Header(Outline)]
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		_OutlineThicknes("Outline Thickness",Range(0,1)) = 0.03
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
				float2 uv: TEXCOORD0;
			};

			fixed4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 col = tex2D(_MainTex,i.uv);
				col *= _Tint;
				return col;
			}

			ENDCG
		}

		Pass
		{
			Cull Front
			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
			};

			fixed4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 _OutlineColor;
			float _OutlineThicknes;

			v2f vert(appdata v)
			{
				v2f o;

				float3 normal = normalize(v.normal);
				float3 outlineOffset = normal * _OutlineThicknes;
				float3 position = v.vertex + outlineOffset;

				o.position = UnityObjectToClipPos(position);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				return _OutlineColor;
			}

			ENDCG
		}
	}
}