Shader "Tutorial/ClipWithPlane"
{
	Properties{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness",Range(0,1)) = .5
		_Metallic("Metalness",Range(0,1)) = .5
		[HDR] _Emission("Emission",Color) = (0,0,0,1)
		[HDR] _CutoffColor("Cutoff Color", Color) = (1,0,0,0)
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}
		Cull Off
		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
			
		struct Input
		{
			float2 uv_MainTex;
			float3 worldPos;
			float facing : VFACE;
		};
			
		sampler2D _MainTex;
		fixed4 _Color;
		half _Smoothness;
		half _Metallic;
		half3 _Emission;
		float4 _CutoffColor;

		float4 _Plane;

		void surf(Input i, inout SurfaceOutputStandard o)
		{
			float distance = dot(i.worldPos, _Plane.xyz);
			distance += _Plane.w;
			clip(-distance);
			
			float facing = i.facing *0.5 + 0.5;
			
			fixed4 col = tex2D(_MainTex, i.uv_MainTex);
			col *= _Color;
			o.Albedo = col.rgb * facing;
			o.Smoothness = _Smoothness * facing;
			o.Metallic = _Metallic * facing;

			o.Emission = lerp(_CutoffColor,_Emission,facing);

		}
		ENDCG
	}
	FallBack "Standard"
}


