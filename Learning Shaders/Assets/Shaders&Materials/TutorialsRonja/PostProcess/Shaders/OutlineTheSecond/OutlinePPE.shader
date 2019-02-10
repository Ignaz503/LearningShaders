Shader "Tutorial/PostProcess/OutlinePPE"
{
	Properties
	{
		[HideInInspector]_MainTex("Texture",2D) = "while"{}
		_NormalMult("Normale Outline Multiplier",Range(0,4)) = 1
		[PowerSlider(4)]_NormalBias("Normal Outline Bias", Range(1,4)) = 1
		_DepthMult("Depth Multiplier", Range(0,4)) = 1
		[PowerSlider(4)]_DepthBias("Depth Outline Bias", Range(1,4)) = 1
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
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
			float4 _CameraDepthNormalsTexture_TexelSize;

			float _NormalMult;
			float _NormalBias;
			float _DepthMult;
			float _DepthBias;
			float4 _OutlineColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			void Compare(inout float depthOutline, inout float normalOutline,float baseDepth, float3 baseNormal, float2 uv, float2 offset)
			{
				float4 neighbordepthNormal = tex2D(_CameraDepthNormalsTexture, uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);
				float3 neighborNormal;
				float neighborDepth;
				DecodeDepthNormal(neighbordepthNormal, neighborDepth, neighborNormal);
				neighborDepth = neighborDepth * _ProjectionParams.z;

				//float normDiff = 1 - dot(baseNormal, neighborNormal);
				//normalOutline += normDiff;
				float3 normalDiff = baseNormal - neighborNormal;
				normalDiff = normalDiff.r + normalDiff.g + normalDiff.b;
				normalOutline += normalDiff;

				float dpethDiff = baseDepth - neighborDepth;
				depthOutline += dpethDiff;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float4 source = tex2D(_MainTex, i.uv);

				float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
				float3 normal;
				float depth;
				DecodeDepthNormal(depthNormal, depth, normal);
				depth = depth * _ProjectionParams.z;

				float depthDifference = 0;
				float normalDifference = 0;
				Compare(depthDifference, normalDifference,depth, normal, i.uv, float2(1, 0));
				Compare(depthDifference, normalDifference,depth, normal, i.uv, float2(0, 1));
				Compare(depthDifference, normalDifference,depth, normal, i.uv, float2(0, -1));
				Compare(depthDifference, normalDifference,depth, normal, i.uv, float2(-1, 0));
				
				depthDifference *= _DepthMult;
				depthDifference = saturate(depthDifference);
				depthDifference = pow(depthDifference, _DepthBias);

				normalDifference *= _NormalMult;
				normalDifference = saturate(normalDifference);
				normalDifference = pow(normalDifference, _NormalBias);

				float outline = depthDifference + normalDifference;
				float4 col = lerp(source, _OutlineColor, outline);
				return col;
			}

			ENDCG
		}
	}
}