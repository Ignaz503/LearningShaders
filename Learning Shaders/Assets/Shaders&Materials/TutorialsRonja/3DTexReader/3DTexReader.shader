Shader "Tutorial/3DTexReader"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
		_Color("Tint",Color) = (1,1,1,1)
		_Height("Height",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler3D _MainTex;
            float4 _MainTex_ST;
			float _Height;
			fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex3D(_MainTex,float3(i.uv,_Height));
				col *= _Color;
				return col;
            }
            ENDCG
        }
    }
}
