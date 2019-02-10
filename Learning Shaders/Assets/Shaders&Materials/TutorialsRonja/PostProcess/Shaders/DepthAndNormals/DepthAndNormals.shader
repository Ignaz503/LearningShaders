Shader "Tutorial/PostProcess/DepthAndNormals"
{
	Properties
	{
		[HideInInspector]_MainTex("Texture",2D) = "while"{}
		_UpCutOff("Up Cut Off",Range(0,1)) = .5
	    _UpColor("Up Color",Color) = (1,1,1,1)
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
			sampler2D _CameraDepthNormalsTexture;
			float4x4 _viewToWorld;

			float _UpCutOff;
			fixed4 _UpColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 source = tex2D(_MainTex, i.uv);
				float4 depthnormal = tex2D(_CameraDepthNormalsTexture,i.uv);

				float3 normal;
				
				float depth;
				DecodeDepthNormal(depthnormal, depth, normal);
				normal = mul((float3x3)_viewToWorld, normal);

				float up = dot(float3(0, 1, 0), normal);
				up = step(_UpCutOff, up);
				float4 col = lerp(source, _UpColor, up * _UpColor.a);
				return col;
			}

			ENDCG
		}
	}
}