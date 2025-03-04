// Made with Amplify Shader Editor v1.9.2.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Faycrest/BuiltIn/FaycrestTreeShader"
{
	Properties
	{
		_AlbedoMap("AlbedoMap", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.6
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_NormalMap("NormalMap", 2D) = "bump" {}
		_MSTAOMap("MSTAOMap", 2D) = "white" {}
		_WindDirection("WindDirection", Vector) = (0,0,0,0)
		_WindStrength("WindStrength", Float) = 0
		_WindFrequency("WindFrequency", Float) = 0
		_TurbulenceStrength("TurbulenceStrength", Float) = 0
		_TurbulenceFrequency("TurbulenceFrequency", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#pragma target 4.6
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#endif//ASE Sampling Macros

		#pragma exclude_renderers gles 
		#pragma surface surf StandardCustom keepalpha addshadow fullforwardshadows exclude_path:deferred dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Translucency;
		};

		uniform float _WindStrength;
		uniform float _WindFrequency;
		uniform float2 _WindDirection;
		uniform float _TurbulenceStrength;
		uniform float _TurbulenceFrequency;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap);
		uniform float4 _NormalMap_ST;
		SamplerState sampler_NormalMap;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_AlbedoMap);
		uniform float4 _AlbedoMap_ST;
		SamplerState sampler_AlbedoMap;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MSTAOMap);
		uniform float4 _MSTAOMap_ST;
		SamplerState sampler_MSTAOMap;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _Cutoff = 0.6;


		inline float2 ASESafeNormalize(float2 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 normalizeResult284 = ASESafeNormalize( _WindDirection );
			float2 dir356 = normalizeResult284;
			float3 objToWorld353 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult354 = (float2(objToWorld353.x , objToWorld353.z));
			float2 panner348 = ( ( _Time.y * _WindFrequency ) * dir356 + appendResult354);
			float simplePerlin2D266 = snoise( panner348*0.01 );
			simplePerlin2D266 = simplePerlin2D266*0.5 + 0.5;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float clampResult320 = clamp( ( ( ase_vertex3Pos.y - 2.0 ) / 60.0 ) , 0.0 , 1.0 );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult350 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 panner349 = ( ( _Time.y * _TurbulenceFrequency ) * dir356 + appendResult350);
			float simplePerlin2D264 = snoise( panner349 );
			simplePerlin2D264 = simplePerlin2D264*0.5 + 0.5;
			float temp_output_276_0 = ( ( ( ( _WindStrength / 2.0 ) * simplePerlin2D266 ) * clampResult320 ) + ( ( _TurbulenceStrength * simplePerlin2D264 ) * v.color.g * v.texcoord1.xy.y ) );
			float temp_output_278_0 = ( v.texcoord1.y * temp_output_276_0 );
			float temp_output_281_0 = ( temp_output_278_0 * temp_output_278_0 );
			float2 break287 = ( ( ( temp_output_281_0 * temp_output_281_0 ) - temp_output_276_0 ) * normalizeResult284 );
			float4 appendResult288 = (float4(break287.x , 0.0 , break287.y , 0.0));
			float4 transform290 = mul(unity_WorldToObject,appendResult288);
			v.vertex.xyz += transform290.xyz;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !defined(DIRECTIONAL)
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackNormal( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, uv_NormalMap ) );
			float2 uv_AlbedoMap = i.uv_texcoord * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
			float4 tex2DNode93 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap );
			o.Albedo = tex2DNode93.rgb;
			float2 uv_MSTAOMap = i.uv_texcoord * _MSTAOMap_ST.xy + _MSTAOMap_ST.zw;
			float4 tex2DNode95 = SAMPLE_TEXTURE2D( _MSTAOMap, sampler_MSTAOMap, uv_MSTAOMap );
			o.Metallic = tex2DNode95.r;
			o.Smoothness = tex2DNode95.a;
			float clampResult135 = clamp( ( tex2DNode95.b * i.vertexColor.a ) , 0.5 , 1.0 );
			o.Occlusion = clampResult135;
			float3 temp_cast_1 = (tex2DNode95.g).xxx;
			o.Translucency = temp_cast_1;
			o.Alpha = 1;
			clip( tex2DNode93.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19201
Node;AmplifyShaderEditor.CommentaryNode;231;-2752.02,460.0742;Inherit;False;3459.85;1896.822;;17;290;288;287;286;285;284;283;281;278;276;275;273;233;232;322;282;356;VERTEX POSITION;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;233;-2694.049,517.3521;Inherit;False;1323.686;603.8845;;15;274;266;265;261;255;252;243;318;319;321;320;348;353;354;358;Main Wind Calculations;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;232;-2690.906,1165.119;Inherit;False;1358.985;649.4601;;12;267;264;258;249;242;236;323;326;349;350;351;359;Turbulence Wind Calculations;1,1,1,1;0;0
Node;AmplifyShaderEditor.TimeNode;252;-2434.647,851.336;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;243;-2415.446,1016.036;Inherit;False;Property;_WindFrequency;WindFrequency;13;0;Create;True;0;0;0;False;0;False;0;16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;-4.031372,828.0554;Inherit;False;dir;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TimeNode;242;-2382.432,1533.679;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;351;-2522.979,1313.269;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;236;-2425.021,1684.872;Inherit;False;Property;_TurbulenceFrequency;TurbulenceFrequency;15;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;249;-2143.232,1562.279;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;359;-2151.51,1418.388;Inherit;False;356;dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;358;-2241.222,761.2468;Inherit;False;356;dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;354;-2281.885,649.8464;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;350;-2294.141,1351.616;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-2187.446,856.9361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;319;-1821.834,868.8609;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;349;-1959.607,1349.53;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-1966.297,562.3521;Inherit;False;Property;_WindStrength;WindStrength;12;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;265;-1733.624,558.9395;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;258;-2173.289,1208.119;Inherit;False;Property;_TurbulenceStrength;TurbulenceStrength;14;0;Create;True;0;0;0;False;0;False;0;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;266;-1744.809,649.7342;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;321;-1646.8,878.8403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;60;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;264;-1733.802,1344.501;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-1532.362,625.9464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;320;-1502.326,880.369;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;-1480.923,1216.598;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;323;-1545.001,1440.716;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-1227.057,743.5914;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-1289.924,1216.405;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;276;-982.6057,809.0629;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;-771.4054,594.0626;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;-467.0768,596.0742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-287.0758,510.0743;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;33.81267,571.7042;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;287;188.386,571.4615;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.VertexColorNode;99;45.76208,269.2079;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;288;327.3694,572.2785;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;309.3174,343.1158;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;290;493.8297,570.9011;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;93;193.3888,-354.4161;Inherit;True;Property;_AlbedoMap;AlbedoMap;0;0;Create;True;0;0;0;False;0;False;-1;None;48f671d426b07d240ba3cdb22c7cd662;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;135;507.1603,339.3544;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;862.0004,8.360548;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Faycrest/BuiltIn/FaycrestTreeShader;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.6;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;11;d3d11;glcore;gles3;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;0;2;0;2;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;2;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.PosVertexDataNode;318;-2010.409,815.3019;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;285;-131.0757,571.0743;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;275;-1062.977,569.8525;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;284;-155.4857,753.0515;Inherit;False;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;326;-1599.368,1626.752;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;353;-2535.75,626.0306;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;348;-2019.273,654.2726;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;95;-8.291428,52.08087;Inherit;True;Property;_MSTAOMap;MSTAOMap;10;0;Create;True;0;0;0;False;0;False;-1;None;7dc884b710ac7a14099addeb2e42b624;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;94;194.2516,-158.2252;Inherit;True;Property;_NormalMap;NormalMap;9;0;Create;True;0;0;0;False;0;False;-1;None;3e6f1b1ea6617494ca32a0b3d769209f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;282;-358.9185,745.5746;Inherit;False;Property;_WindDirection;WindDirection;11;0;Create;True;0;0;0;False;0;False;0,0;0.9,0.45;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
WireConnection;356;0;284;0
WireConnection;249;0;242;2
WireConnection;249;1;236;0
WireConnection;354;0;353;1
WireConnection;354;1;353;3
WireConnection;350;0;351;1
WireConnection;350;1;351;3
WireConnection;255;0;252;2
WireConnection;255;1;243;0
WireConnection;319;0;318;2
WireConnection;349;0;350;0
WireConnection;349;2;359;0
WireConnection;349;1;249;0
WireConnection;265;0;261;0
WireConnection;266;0;348;0
WireConnection;321;0;319;0
WireConnection;264;0;349;0
WireConnection;274;0;265;0
WireConnection;274;1;266;0
WireConnection;320;0;321;0
WireConnection;267;0;258;0
WireConnection;267;1;264;0
WireConnection;322;0;274;0
WireConnection;322;1;320;0
WireConnection;273;0;267;0
WireConnection;273;1;323;2
WireConnection;273;2;326;2
WireConnection;276;0;322;0
WireConnection;276;1;273;0
WireConnection;278;0;275;2
WireConnection;278;1;276;0
WireConnection;281;0;278;0
WireConnection;281;1;278;0
WireConnection;283;0;281;0
WireConnection;283;1;281;0
WireConnection;286;0;285;0
WireConnection;286;1;284;0
WireConnection;287;0;286;0
WireConnection;288;0;287;0
WireConnection;288;2;287;1
WireConnection;98;0;95;3
WireConnection;98;1;99;4
WireConnection;290;0;288;0
WireConnection;135;0;98;0
WireConnection;0;0;93;0
WireConnection;0;1;94;0
WireConnection;0;3;95;1
WireConnection;0;4;95;4
WireConnection;0;5;135;0
WireConnection;0;7;95;2
WireConnection;0;10;93;4
WireConnection;0;11;290;0
WireConnection;285;0;283;0
WireConnection;285;1;276;0
WireConnection;284;0;282;0
WireConnection;348;0;354;0
WireConnection;348;2;358;0
WireConnection;348;1;255;0
ASEEND*/
//CHKSM=8D90F8BD851C6B9F68CC4FDB10BF055540145062