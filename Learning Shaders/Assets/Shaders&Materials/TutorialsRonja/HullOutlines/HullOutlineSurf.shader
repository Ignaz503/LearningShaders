Shader "Tutorial/HullOutlineSurf"
{
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness",Range(0,1)) = .5
		_Metallic("Metalness",Range(0,1)) = .5
		[HDR] _Emission("Emission",Color) = (0,0,0,1)

		[Header(Outline)]
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		_OutlineThicknes("Outline Thickness",Range(0,1)) = 0.03
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
			
		struct Input
		{
			float2 uv_MainTex;
		};
			
		sampler2D _MainTex;
		fixed4 _Color;
		half _Smoothness;
		half _Metallic;
		half3 _Emission;

		void surf(Input i, inout SurfaceOutputStandard o)
		{
			fixed4 col = tex2D(_MainTex, i.uv_MainTex);
			col *= _Color;
			o.Albedo = col.rgb;
			o.Smoothness = _Smoothness;
			o.Metallic = _Metallic;
			o.Emission = _Emission;
		}
		ENDCG
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
	FallBack "Standard"
}


