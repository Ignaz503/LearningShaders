Shader "Tutorial/TriPlanarMapping"
{
	Properties
	{
		_Color("Color",Color) = (0,0,0,1)
		_MainTex("Texture",2D) = "while"{}
		_Sharpness("Sharpness",Range(1,64)) = 1
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
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPos: TEXCOORD0;
				float3 normal : NORMAL;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Sharpness;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldPos = worldPos.xyz;
				
				float3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.normal = normalize(worldNormal);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float3 weights = i.normal;
				weights = abs(weights);
				weights = pow(weights, _Sharpness);

				weights = weights / (weights.x + weights.y + weights.z);

				float2 uv_front = TRANSFORM_TEX(i.worldPos.xy,_MainTex);
				float2 uv_side = TRANSFORM_TEX(i.worldPos.zy,_MainTex);
				float2 uv_top = TRANSFORM_TEX(i.worldPos.xz,_MainTex);

				fixed4 col_front = tex2D(_MainTex, uv_front);
				fixed4 col_side = tex2D(_MainTex, uv_side);
				fixed4 col_top = tex2D(_MainTex, uv_top);
				
				col_front *= weights.z;
				col_side *= weights.x;
				col_top *= weights.y;

				fixed4 col = (col_front + col_side + col_top);
				col *= _Color;
				return col;

			}

			ENDCG
		}
	}
}