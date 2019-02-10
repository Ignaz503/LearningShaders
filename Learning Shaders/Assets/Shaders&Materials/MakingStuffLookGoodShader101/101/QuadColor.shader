Shader "MakingStuffLookGood/QuadColor"
{
    Properties
    {
		_Color("Color",Color) = (0,0,0,1)
		_MainTex("Main Tex",2D) = "white"{}
		_SecondTex("SecondTex",2D) = "white"{}
		_T("Lerp Amount",Range(0,1)) = 0
		_B("Blue Amount",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

			float4 _Color;
			
			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler _SecondTex;
			float4 _SecondTex_ST;

			float _T;
			float _B;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _SecondTex);
				//o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 col = lerp(tex2D(_MainTex,i.uv),tex2D(_SecondTex,i.uv2),_T);
				col *= _Color * float4(i.uv, _B, 1);
				return col;
            }
            ENDCG
        }
    }
}
