Shader "Custom/BlendedSkybox"
{
    Properties
    {
        _DayCubemap ("Day Cubemap", Cube) = "white" {}
        _EveningCubemap ("Evening Cubemap", Cube) = "white" {}
        _NightCubemap ("Night Cubemap", Cube) = "white" {}
        _BlendFactor ("Blend Factor", Range(0, 2)) = 0 // 0 = Day, 1 = Evening, 2 = Night
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 uv : TEXCOORD0;
            };

            samplerCUBE _DayCubemap;
            samplerCUBE _EveningCubemap;
            samplerCUBE _NightCubemap;
            float _BlendFactor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.vertex.xyz; // Use vertex position as UV for cubemap
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Sample the three cubemaps
                fixed4 dayColor = texCUBE(_DayCubemap, i.uv);
                fixed4 eveningColor = texCUBE(_EveningCubemap, i.uv);
                fixed4 nightColor = texCUBE(_NightCubemap, i.uv);

                // Blend between the cubemaps based on _BlendFactor
                fixed4 blendedColor;
                if (_BlendFactor <= 1)
                {
                    blendedColor = lerp(dayColor, eveningColor, _BlendFactor);
                }
                else
                {
                    blendedColor = lerp(eveningColor, nightColor, _BlendFactor - 1);
                }

                return blendedColor;
            }
            ENDCG
        }
    }
}