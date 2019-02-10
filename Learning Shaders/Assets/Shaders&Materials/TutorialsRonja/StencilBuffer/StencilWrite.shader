Shader "Tutorial/StencilWrite"
{
	Properties
	{
		[IntRange]_StencilRef("Stencil Reference",Range(0,255)) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Geometry-1"
		}
		Blend Zero One
		ZWrite Off
		Pass
		{
			
			Stencil
			{
				Ref[_StencilRef]
				Comp Always
				Pass Replace
			}
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
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				return 0;
			}

			ENDCG
		}
	}
}