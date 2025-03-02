// Made with Amplify Shader Editor v1.9.2.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Faycrest/BuiltIn/FaycrestDetailShader"
{
	Properties
	{
		_AlbedoMap("AlbedoMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_MSTAOMap("MSTAOMap", 2D) = "white" {}
		_WindDirection("WindDirection", Vector) = (0,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.44
		_WindStrength("WindStrength", Float) = 0
		_WindFrequency("WindFrequency", Float) = 0
		_TurbulenceStrength("TurbulenceStrength", Float) = 0
		_TurbulenceFrequency("TurbulenceFrequency", Float) = 0
		_DetailDistance("DetailDistance", Float) = 50
		[HideInInspector]_FadeDistance("FadeDistance", Float) = 10
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		Blend One Zero , SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.0
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex2Dlod(tex,float4(coord,0,lod))
		#endif//ASE Sampling Macros

		#pragma exclude_renderers gles 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			half ASEIsFrontFacing : VFACE;
			float4 vertexColor : COLOR;
		};

		uniform half _WindStrength;
		uniform half _WindFrequency;
		uniform half2 _WindDirection;
		uniform half _TurbulenceStrength;
		uniform half _TurbulenceFrequency;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MSTAOMap);
		uniform half4 _MSTAOMap_ST;
		SamplerState sampler_MSTAOMap;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap);
		uniform half4 _NormalMap_ST;
		SamplerState sampler_NormalMap;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_AlbedoMap);
		uniform half4 _AlbedoMap_ST;
		SamplerState sampler_AlbedoMap;
		uniform half _DetailDistance;
		uniform half _FadeDistance;
		uniform float _Cutoff = 0.44;


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
			half2 normalizeResult124 = ASESafeNormalize( _WindDirection );
			half2 dir228 = normalizeResult124;
			half3 objToWorld234 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			half2 appendResult154 = (half2(objToWorld234.x , objToWorld234.z));
			half2 panner226 = ( ( _Time.y * _WindFrequency ) * dir228 + appendResult154);
			half simplePerlin2D13 = snoise( panner226*0.01 );
			simplePerlin2D13 = simplePerlin2D13*0.5 + 0.5;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half2 appendResult230 = (half2(ase_worldPos.x , ase_worldPos.z));
			half2 panner232 = ( ( _Time.y * _TurbulenceFrequency ) * dir228 + appendResult230);
			half simplePerlin2D22 = snoise( panner232 );
			simplePerlin2D22 = simplePerlin2D22*0.5 + 0.5;
			half temp_output_30_0 = ( ( ( ( _WindStrength / 32.0 ) * simplePerlin2D13 ) + ( ( _TurbulenceStrength / 30.0 ) * simplePerlin2D22 ) ) + 1.0 );
			half temp_output_31_0 = ( temp_output_30_0 * temp_output_30_0 );
			half2 break42 = ( ( ( temp_output_31_0 * temp_output_31_0 ) - temp_output_30_0 ) * normalizeResult124 );
			half4 appendResult43 = (half4(break42.x , 0.0 , break42.y , 0.0));
			half4 transform134 = mul(unity_WorldToObject,appendResult43);
			v.vertex.xyz += ( v.color.a * transform134 ).xyz;
			v.vertex.w = 1;
			half3 ase_vertexNormal = v.normal.xyz;
			float2 uv_MSTAOMap = v.texcoord * _MSTAOMap_ST.xy + _MSTAOMap_ST.zw;
			half4 tex2DNode95 = SAMPLE_TEXTURE2D_LOD( _MSTAOMap, sampler_MSTAOMap, uv_MSTAOMap, 0.0 );
			half3 temp_cast_1 = (tex2DNode95.g).xxx;
			float4 ase_vertex4Pos = v.vertex;
			half3 ase_objectlightDir = normalize( ObjSpaceLightDir( ase_vertex4Pos ) );
			half3 lerpResult244 = lerp( ase_vertexNormal , temp_cast_1 , ase_objectlightDir);
			v.normal = lerpResult244;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			half3 tex2DNode94 = UnpackNormal( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, uv_NormalMap ) );
			half3 appendResult166 = (half3(tex2DNode94.r , tex2DNode94.g , ( tex2DNode94.b * i.ASEIsFrontFacing )));
			o.Normal = appendResult166;
			float2 uv_AlbedoMap = i.uv_texcoord * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
			half4 tex2DNode93 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap );
			o.Albedo = tex2DNode93.rgb;
			float2 uv_MSTAOMap = i.uv_texcoord * _MSTAOMap_ST.xy + _MSTAOMap_ST.zw;
			half4 tex2DNode95 = SAMPLE_TEXTURE2D( _MSTAOMap, sampler_MSTAOMap, uv_MSTAOMap );
			o.Smoothness = tex2DNode95.a;
			half clampResult135 = clamp( ( tex2DNode95.b * i.vertexColor.a ) , 0.5 , 1.0 );
			o.Occlusion = clampResult135;
			o.Alpha = 1;
			float3 ase_worldPos = i.worldPos;
			half clampResult197 = clamp( ( distance( ase_worldPos , _WorldSpaceCameraPos ) - _DetailDistance ) , 0.0 , _FadeDistance );
			half lerpResult190 = lerp( 1.1 , _Cutoff , ( clampResult197 / _FadeDistance ));
			clip( ( tex2DNode93.a * lerpResult190 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19201
Node;AmplifyShaderEditor.CommentaryNode;105;-3524.162,772.3018;Inherit;False;3457.18;1577.011;;14;27;30;31;32;33;41;34;42;43;124;134;156;162;228;VERTEX POSITION;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;162;-3079.182,1557.499;Inherit;False;1480.063;684.5848;;14;68;66;21;22;24;69;23;52;51;53;230;231;232;233;Turbulence Wind Calculations;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;156;-3082.872,906.5515;Inherit;False;1435.388;625.6078;;11;14;13;15;10;9;154;12;165;226;229;234;Main Wind Calculations;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;124;-921.209,1013.494;Inherit;False;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;228;-720.4194,1113.454;Inherit;False;dir;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1358.484,906.2471;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1215.872,908.3016;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1035.871,822.3017;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-879.8712,883.3017;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-714.9828,883.9314;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;194;-1056,-96;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;42;-560.4097,883.6889;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;196;-880,-80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;197;-704,-80;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;30;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;43;-421.4264,884.5059;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;164;-227.4834,589.2017;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;198;-432,-80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;134;-236.7477,884.8819;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;94;-432.9005,-411.2972;Inherit;True;Property;_NormalMap;NormalMap;1;0;Create;True;0;0;0;False;0;False;-1;None;f5e128d1460a01244a4814534e0e3434;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;99;-451.0283,331.2188;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FaceVariableNode;167;-6.84771,-214.5747;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;181.1523,-268.5746;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-187.4727,405.1268;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;10.37608,859.4834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;190;-46.10416,-126.4071;Inherit;False;3;0;FLOAT;1.1;False;1;FLOAT;1.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;166;381.2543,-325.2326;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;135;99.67732,408.4534;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;192;-1375.586,-96;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;191;-1439.586,64.00004;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;231;-2968.78,1725.791;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TimeNode;51;-2741.378,1944.371;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-2776.589,2101.074;Inherit;False;Property;_TurbulenceFrequency;TurbulenceFrequency;8;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;9;-2659.812,1196.259;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-2656.669,1364.022;Inherit;False;Property;_WindFrequency;WindFrequency;6;0;Create;True;0;0;0;False;0;False;0;16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;234;-2928.922,966.5921;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;154;-2612.471,1002.713;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-2502.178,1972.972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2425.611,1220.858;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2669.236,1625.813;Inherit;False;Property;_TurbulenceStrength;TurbulenceStrength;7;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-2507.197,1094.029;Inherit;False;228;dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;230;-2594.308,1750.309;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-2505.674,1848.824;Inherit;False;228;dir;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;69;-2232.33,1623.332;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;232;-2267.59,1767.583;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2268.418,966.2741;Inherit;False;Property;_WindStrength;WindStrength;5;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;226;-2269.113,1056.681;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-1975.388,1629.855;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;30;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;13;-2055.929,1059.657;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;22;-2028.747,1749.194;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;165;-1998.584,965.5511;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;32;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1809.483,1037.869;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1784.869,1630.292;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-2438.726,2141.918;Inherit;False;turbulenceFreq;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-2289.726,1676.052;Inherit;False;turbulenceStre;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1530.048,896.1588;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1747.634,31.58863;Half;False;True;-1;4;ASEMaterialInspector;0;0;Standard;Faycrest/BuiltIn/FaycrestDetailShader;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;5;Custom;0.44;True;True;0;True;TransparentCutout;;Geometry;All;11;d3d11;glcore;gles3;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;2;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;4;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;645.0532,-111.9347;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-339.169,-207.2801;Inherit;False;Global;_Cutoff;_Cutoff;10;0;Fetch;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;93;165.7719,-649.5907;Inherit;True;Property;_AlbedoMap;AlbedoMap;0;0;Create;True;0;0;0;False;0;False;-1;None;fc6e43150df115043ba377c334a60f0d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;171;-1363,217;Inherit;False;Property;_DetailDistance;DetailDistance;9;0;Create;True;0;0;0;False;0;False;50;60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;200;-1360,-228;Inherit;False;Property;_FadeDistance;FadeDistance;10;1;[HideInInspector];Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;95;-505.0818,114.0918;Inherit;True;Property;_MSTAOMap;MSTAOMap;2;0;Create;True;0;0;0;False;0;False;-1;None;b110ea5f91971ad489daa1b07ba4e9d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;41;-1112.252,1010.669;Inherit;False;Property;_WindDirection;WindDirection;3;0;Create;True;0;0;0;False;0;False;0,0;0.9,0.45;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;244;1292.564,860.0546;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjSpaceLightDirHlpNode;236;842.175,1162.014;Inherit;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;241;904.0597,980.0442;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;124;0;41;0
WireConnection;228;0;124;0
WireConnection;30;0;27;0
WireConnection;31;0;30;0
WireConnection;31;1;30;0
WireConnection;32;0;31;0
WireConnection;32;1;31;0
WireConnection;33;0;32;0
WireConnection;33;1;30;0
WireConnection;34;0;33;0
WireConnection;34;1;124;0
WireConnection;194;0;192;0
WireConnection;194;1;191;0
WireConnection;42;0;34;0
WireConnection;196;0;194;0
WireConnection;196;1;171;0
WireConnection;197;0;196;0
WireConnection;197;2;200;0
WireConnection;43;0;42;0
WireConnection;43;2;42;1
WireConnection;198;0;197;0
WireConnection;198;1;200;0
WireConnection;134;0;43;0
WireConnection;168;0;94;3
WireConnection;168;1;167;0
WireConnection;98;0;95;3
WireConnection;98;1;99;4
WireConnection;163;0;164;4
WireConnection;163;1;134;0
WireConnection;190;1;189;0
WireConnection;190;2;198;0
WireConnection;166;0;94;1
WireConnection;166;1;94;2
WireConnection;166;2;168;0
WireConnection;135;0;98;0
WireConnection;154;0;234;1
WireConnection;154;1;234;3
WireConnection;52;0;51;2
WireConnection;52;1;53;0
WireConnection;10;0;9;2
WireConnection;10;1;12;0
WireConnection;230;0;231;1
WireConnection;230;1;231;3
WireConnection;69;0;23;0
WireConnection;232;0;230;0
WireConnection;232;2;233;0
WireConnection;232;1;52;0
WireConnection;226;0;154;0
WireConnection;226;2;229;0
WireConnection;226;1;10;0
WireConnection;24;0;69;0
WireConnection;13;0;226;0
WireConnection;22;0;232;0
WireConnection;165;0;15;0
WireConnection;14;0;165;0
WireConnection;14;1;13;0
WireConnection;21;0;24;0
WireConnection;21;1;22;0
WireConnection;66;0;53;0
WireConnection;68;0;23;0
WireConnection;27;0;14;0
WireConnection;27;1;21;0
WireConnection;0;0;93;0
WireConnection;0;1;166;0
WireConnection;0;4;95;4
WireConnection;0;5;135;0
WireConnection;0;10;199;0
WireConnection;0;11;163;0
WireConnection;0;12;244;0
WireConnection;199;0;93;4
WireConnection;199;1;190;0
WireConnection;244;0;241;0
WireConnection;244;1;95;2
WireConnection;244;2;236;0
ASEEND*/
//CHKSM=F84AF9EE5A1183B46B443931E961B0166117B535