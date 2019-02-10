Shader "Tutorial/SurfScreenSpace"
{
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness",Range(0,1)) = .5
		_Metallic("Metalness",Range(0,1)) = .5
		[HDR] _Emission("Emission",Color) = (0,0,0,1)
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
			
		struct Input
		{
			float4 screenPos;
		};
			
		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;
		half _Smoothness;
		half _Metallic;
		half3 _Emission;

		void surf(Input i, inout SurfaceOutputStandard o)
		{
			float2 texCoord = i.screenPos.xy / i.screenPos.w;

			float aspectRatio = _ScreenParams.x / _ScreenParams.y;
			texCoord.x *= aspectRatio;

			texCoord = TRANSFORM_TEX(texCoord, _MainTex);


			fixed4 col = tex2D(_MainTex, texCoord);
			col *= _Color;
			o.Albedo = col.rgb;
			o.Smoothness = _Smoothness;
			o.Metallic = _Metallic;
			o.Emission = _Emission;
		}
		ENDCG
	}
	FallBack "Standard"
}


