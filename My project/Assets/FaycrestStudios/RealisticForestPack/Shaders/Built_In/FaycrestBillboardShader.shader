// Made with Amplify Shader Editor v1.9.2.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Faycrest/BuiltIn/FaycrestBillboardShader"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.6
		_AlbedoMap("AlbedoMap", 2D) = "white" {}
		_STAOMap("STAOMap", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "DisableBatching" = "LODFading" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 2.5
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#endif//ASE Sampling Macros

		#pragma exclude_renderers gles 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		UNITY_DECLARE_TEX2D_NOSAMPLER(_AlbedoMap);
		uniform half4 _AlbedoMap_ST;
		SamplerState sampler_AlbedoMap;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_STAOMap);
		uniform half4 _STAOMap_ST;
		SamplerState sampler_STAOMap;
		uniform float _Cutoff = 0.6;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half4 transform22 = mul(unity_WorldToObject,half4( ( _WorldSpaceCameraPos - ase_worldPos ) , 0.0 ));
			half clampResult28 = clamp( ( distance( _WorldSpaceCameraPos , ase_worldPos ) - 500.0 ) , 0.0 , 800.0 );
			half4 lerpResult23 = lerp( transform22 , float4( 0,1,0,0 ) , ( clampResult28 / 800.0 ));
			v.normal = lerpResult23.xyz;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_AlbedoMap = i.uv_texcoord * _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
			half4 tex2DNode1 = SAMPLE_TEXTURE2D( _AlbedoMap, sampler_AlbedoMap, uv_AlbedoMap );
			o.Albedo = tex2DNode1.rgb;
			float2 uv_STAOMap = i.uv_texcoord * _STAOMap_ST.xy + _STAOMap_ST.zw;
			half4 tex2DNode2 = SAMPLE_TEXTURE2D( _STAOMap, sampler_STAOMap, uv_STAOMap );
			o.Metallic = tex2DNode2.r;
			o.Smoothness = tex2DNode2.a;
			o.Occlusion = tex2DNode2.b;
			o.Alpha = 1;
			clip( tex2DNode1.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19201
Node;AmplifyShaderEditor.SamplerNode;2;-635.8738,29.83212;Inherit;True;Property;_STAOMap;STAOMap;2;0;Create;True;0;0;0;False;0;False;-1;None;bb27ff0b84b8be24ca692b5e0e27abfb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Half;False;True;-1;1;ASEMaterialInspector;0;0;Standard;Faycrest/BuiltIn/FaycrestBillboardShader;False;False;False;False;False;False;False;False;False;False;False;False;True;LODFading;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.6;True;True;0;True;TransparentCutout;;Geometry;All;11;d3d11;glcore;gles3;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.LerpOp;23;-810.7912,287.1911;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,1,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;24;-1851.946,659.9219;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;25;-1784.833,833.8068;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;26;-1556.39,659.8644;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;-1383.873,661.3473;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;500;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;28;-1194.787,660.2522;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;800;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-1003.621,660.2441;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;800;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-641.7772,-190.1942;Inherit;True;Property;_AlbedoMap;AlbedoMap;1;0;Create;True;0;0;0;False;0;False;-1;None;558efab019f565f4cba5a4a24affbf9d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-1243.338,286.5181;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;22;-1056.192,285.3748;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;19;-1545.348,284.4848;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;20;-1478.235,458.3697;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
WireConnection;0;0;1;0
WireConnection;0;3;2;1
WireConnection;0;4;2;4
WireConnection;0;5;2;3
WireConnection;0;10;1;4
WireConnection;0;12;23;0
WireConnection;23;0;22;0
WireConnection;23;2;29;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;27;0;26;0
WireConnection;28;0;27;0
WireConnection;29;0;28;0
WireConnection;21;0;19;0
WireConnection;21;1;20;0
WireConnection;22;0;21;0
ASEEND*/
//CHKSM=A1C34ED3587EE2BEA33A7220305927192698F586