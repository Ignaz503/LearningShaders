Shader "Tutorial/CheckerBoardShader"
{
    Properties
    {
		_Scale("Scale",Range(0,10)) = 1
        _EvenColor("Even Color",Color) = (0,0,0,1)
		_OddColor("Odd Color",Color) = (1,1,1,1)
    }
    SubShader
    {
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
		}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

			fixed4 _EvenColor;
		    fixed4 _OddColor;
			float _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				//o.worldPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 adjustedPos = floor(i.worldPos / _Scale);

				float chessboard = adjustedPos.x+ adjustedPos.y+ adjustedPos.z;

				chessboard = frac(chessboard *.5f);

				chessboard *= 2;

				return lerp(_EvenColor, _OddColor, chessboard);
            }
            ENDCG
        }
    }
}
