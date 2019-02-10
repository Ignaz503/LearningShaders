Shader "Tutorial/Wobble"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Amplitude("Amplitude",Range(0,1)) = .4
		_Frequency("Frequency",Range(1,8)) = 2
		_AnimationSpeed("Animation Speed", Range(0,5)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		float _Amplitude;
		float _Frequency;
		float _AnimationSpeed;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full data)
		{
			float4 modPos = data.vertex;
			modPos.y += sin(modPos.x*_Frequency + _Time.y * _AnimationSpeed)*_Amplitude;

			float3 posPlusTangent = data.vertex + data.tangent * 0.01;
			posPlusTangent.y += sin(posPlusTangent.x *_Frequency + _Time.y * _AnimationSpeed)*_Amplitude;

			float3 bitangent = cross(data.normal, data.tangent);
			float3 posPlusbitangent = data.vertex + bitangent * 0.01;
			posPlusbitangent.y += sin(posPlusbitangent.x*_Frequency + _Time.y * _AnimationSpeed)*_Amplitude;

			float3 modifiedTangent = posPlusTangent - modPos;
			float3 modifiedBiTangent = posPlusbitangent - modPos;

			float3 modNormal = cross(modifiedTangent, modifiedBiTangent);
			data.normal = normalize(modNormal);

			data.vertex = modPos;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
