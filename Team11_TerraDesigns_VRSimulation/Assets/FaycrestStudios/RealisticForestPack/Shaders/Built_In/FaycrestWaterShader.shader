// Made with Amplify Shader Editor v1.9.2.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Faycrest/BuiltIn/FaycrestWaterShader"
{
	Properties
	{
		_MainColor("MainColor", Color) = (0.2882698,0.4834222,0.7735849,0)
		_HighlightColor("HighlightColor", Color) = (0.2882698,0.4834222,0.7735849,0)
		_FadeStart("FadeStart", Float) = 50
		_FadeDistance("FadeDistance", Float) = 10
		_WaterNormal("WaterNormal", 2D) = "bump" {}
		_NormalIntensity("NormalIntensity", Float) = 1
		_WaterWaveTexture("WaterWaveTexture", 2D) = "white" {}
		_WaveSpeed("WaveSpeed", Float) = 1
		_WaveStrength("WaveStrength", Float) = 1
		_SeaFoam("SeaFoam", 2D) = "white" {}
		_EdgeStrength("EdgeStrength", Float) = 1
		_EdgeDistance("EdgeDistance", Float) = 1
		_RefractAmount("RefractAmount", Float) = 0
		_RefractionDepth("RefractionDepth", Float) = 0
		_RefractionClamp("RefractionClamp", Float) = 0
		_NormalSpeed("NormalSpeed", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard alpha:fade keepalpha vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform sampler2D _WaterWaveTexture;
		uniform float _WaveSpeed;
		uniform float _WaveStrength;
		uniform sampler2D _WaterNormal;
		uniform float _NormalSpeed;
		uniform float _NormalIntensity;
		uniform float4 _MainColor;
		uniform float4 _HighlightColor;
		uniform float _FadeStart;
		uniform float _FadeDistance;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _RefractAmount;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _RefractionDepth;
		uniform float _RefractionClamp;
		uniform sampler2D _SeaFoam;
		uniform float _EdgeDistance;
		uniform float _EdgeStrength;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float Time103 = ( _Time.y * ( _WaveSpeed / 16.0 ) );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult41 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 WorldSpace98 = appendResult41;
			float2 panner16 = ( Time103 * float2( 1,1 ) + ( WorldSpace98 / float2( 8.4,8.4 ) ));
			float4 tex2DNode17 = tex2Dlod( _WaterWaveTexture, float4( panner16, 0, 0.0) );
			float2 panner22 = ( Time103 * float2( 1,1 ) + ( WorldSpace98 / float2( 29.7,29.7 ) ));
			float4 tex2DNode20 = tex2Dlod( _WaterWaveTexture, float4( panner22, 0, 0.0) );
			float4 appendResult11 = (float4(0.0 , ( ( tex2DNode17 * ( _WaveStrength / 20.1 ) ) + ( tex2DNode20 * ( _WaveStrength / 4.2 ) ) ).rgb));
			v.vertex.xyz += appendResult11.xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float Time103 = ( _Time.y * ( _WaveSpeed / 16.0 ) );
			float2 temp_cast_0 = (_NormalSpeed).xx;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult41 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 WorldSpace98 = appendResult41;
			float2 panner33 = ( Time103 * temp_cast_0 + ( WorldSpace98 / float2( 6.2,6.2 ) ));
			float2 temp_cast_1 = (( _NormalSpeed * -1.12 )).xx;
			float2 panner42 = ( Time103 * temp_cast_1 + ( WorldSpace98 / float2( 2.4,2.4 ) ));
			float3 Normalmap108 = BlendNormals( UnpackScaleNormal( tex2D( _WaterNormal, panner33 ), _NormalIntensity ) , UnpackScaleNormal( tex2D( _WaterNormal, panner42 ), _NormalIntensity ) );
			o.Normal = Normalmap108;
			float2 panner16 = ( Time103 * float2( 1,1 ) + ( WorldSpace98 / float2( 8.4,8.4 ) ));
			float4 tex2DNode17 = tex2D( _WaterWaveTexture, panner16 );
			float2 panner22 = ( Time103 * float2( 1,1 ) + ( WorldSpace98 / float2( 29.7,29.7 ) ));
			float4 tex2DNode20 = tex2D( _WaterWaveTexture, panner22 );
			float4 Heightmap95 = ( tex2DNode17 + tex2DNode20 );
			float4 lerpResult59 = lerp( _MainColor , _HighlightColor , Heightmap95);
			float clampResult163 = clamp( ( distance( ase_worldPos , _WorldSpaceCameraPos ) - _FadeStart ) , 0.0 , _FadeDistance );
			float4 lerpResult169 = lerp( lerpResult59 , ( lerpResult59 * float4( 0.8,0.8,0.8,1 ) ) , ( clampResult163 / _FadeDistance ));
			float4 BaseAlbedo92 = lerpResult169;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor122 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float3( (ase_grabScreenPosNorm).xy ,  0.0 ) + ( _RefractAmount * Normalmap108 ) ).xy);
			float4 clampResult123 = clamp( screenColor122 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Refraction124 = clampResult123;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth127 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth127 = abs( ( screenDepth127 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _RefractionDepth ) );
			float clampResult129 = clamp( ( 1.0 - distanceDepth127 ) , _RefractionClamp , 0.8 );
			float Depth130 = clampResult129;
			float4 lerpResult155 = lerp( BaseAlbedo92 , Refraction124 , Depth130);
			float4 color145 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float2 panner75 = ( Time103 * float2( 0.9,0.9 ) + ( WorldSpace98 / float2( 8.1,8.1 ) ));
			float2 panner78 = ( Time103 * float2( 1.3,1.3 ) + ( WorldSpace98 / float2( 20.2,20.2 ) ));
			float screenDepth61 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth61 = abs( ( screenDepth61 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _EdgeDistance ) );
			float clampResult69 = clamp( ( ( 1.0 - distanceDepth61 ) * _EdgeStrength ) , 0.0 , 1.0 );
			float4 lerpResult67 = lerp( lerpResult155 , color145 , ( ( color145 * ( tex2D( _SeaFoam, panner75 ) * tex2D( _SeaFoam, panner78 ) ) ) * clampResult69 ));
			float screenDepth83 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth83 = abs( ( screenDepth83 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( _EdgeDistance / 3.0 ) ) );
			float clampResult86 = clamp( ( ( 1.0 - distanceDepth83 ) * ( _EdgeStrength / 2.0 ) ) , 0.0 , 1.0 );
			float4 lerpResult82 = lerp( lerpResult67 , color145 , clampResult86);
			float4 FinalAlbedo139 = lerpResult82;
			o.Albedo = FinalAlbedo139.rgb;
			o.Metallic = 0.0;
			o.Smoothness = 0.9;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19201
Node;AmplifyShaderEditor.CommentaryNode;185;-4657.756,65.82609;Inherit;False;925.3462;351.1971;;5;7;103;8;9;10;TIME CALCS;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;184;-4587.548,-353.8487;Inherit;False;723.8936;235;;3;52;41;98;WORLD SPACE;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;183;-2284.765,1072.991;Inherit;False;2214.188;921.475;;18;4;21;16;22;14;24;17;20;15;13;23;60;11;101;104;19;159;95;WAVE CALCULATIONS;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;172;-2873.82,-5240.98;Inherit;False;1999.745;986.2026;;15;59;97;58;57;161;162;163;164;165;166;168;167;169;92;170;ALBEDO;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;157;-2855.49,-3331.689;Inherit;False;2927.933;1253.834;;32;73;81;79;71;80;75;78;65;61;63;64;69;83;84;86;87;85;88;100;76;77;106;67;62;145;70;82;151;153;154;155;139;SEA FOAM;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;156;-2853.779,-779.743;Inherit;False;1250.61;211.95;;6;129;130;127;128;133;158;REFRACTION DEPTH;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;126;-2838.169,-497.2729;Inherit;False;1466.791;441.6901;;9;110;111;112;113;114;121;124;123;122;REFRACTION;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;107;-2034.469,228.282;Inherit;False;1714.022;719.3888;;14;42;33;44;28;45;105;35;99;34;108;115;117;181;182;NORMALMAP;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;45;-1066.933,720.671;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;115;-743.2212,585.1619;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-525.9761,584.8516;Inherit;False;Normalmap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;35;-1794.175,489.4388;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;6.2,6.2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-1350.741,649.499;Inherit;False;Property;_NormalIntensity;NormalIntensity;5;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-1066.348,437.3765;Inherit;True;Property;_WaterN1;WaterN1;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-2441.608,-262.5828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-2681.608,-168.5828;Inherit;False;108;Normalmap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-2214.919,-443.9607;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;124;-1613.378,-437.6025;Inherit;False;Refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;123;-1815.377,-437.6025;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;111;-2488.422,-443.437;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;-1845.171,-729.743;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;127;-2585.587,-727.531;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;133;-2280.805,-727.6061;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-793.0472,-2565.663;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-1354.744,-2616.901;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;79;-2296.427,-3121.515;Inherit;True;Property;_SeaFoam;SeaFoam;9;0;Create;True;0;0;0;False;0;False;None;9e5f4ab12f0ad844ab69215128350667;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;80;-1856.121,-2745.773;Inherit;True;Property;_texture1;texture0;9;0;Create;True;0;0;0;False;0;False;-1;None;9e5f4ab12f0ad844ab69215128350667;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;75;-2258.052,-2903.262;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.9,0.9;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;78;-2259.882,-2749.665;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.3,1.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1397.208,-2401.984;Inherit;False;Property;_EdgeStrength;EdgeStrength;10;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;61;-1701.208,-2497.984;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;63;-1381.208,-2497.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1205.208,-2481.985;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;69;-1029.208,-2497.984;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;83;-1420.155,-2294.856;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;-1100.154,-2294.856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;86;-748.155,-2294.856;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;87;-1644.155,-2294.856;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-924.1552,-2278.856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-1084.154,-2214.856;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-2805.49,-2824.76;Inherit;False;98;WorldSpace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;76;-2583.749,-2903.177;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;8.1,8.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;77;-2587.423,-2744.313;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;20.2,20.2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-2471.789,-2811.488;Inherit;False;103;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;67;-624.2991,-2816.311;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1975.369,-2486.312;Inherit;False;Property;_EdgeDistance;EdgeDistance;11;0;Create;True;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;145;-1348.482,-2887.807;Inherit;False;Constant;_Color1;Color 0;12;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1048.96,-2643.203;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;82;-439.3888,-2633.208;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-1364.876,-3281.689;Inherit;False;92;BaseAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-1349,-3169.834;Inherit;False;124;Refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-1351.665,-3074.634;Inherit;False;130;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;155;-1076.614,-3191.083;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-169.5573,-2631.517;Inherit;False;FinalAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;129;-2044.779,-728.7931;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;-1854.639,-2941.042;Inherit;True;Property;_texture0;texture0;9;0;Create;True;0;0;0;False;0;False;-1;None;9e5f4ab12f0ad844ab69215128350667;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;59;-2361.101,-5142.272;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-2585.413,-4951.585;Inherit;False;95;Heightmap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;161;-2402.586,-4599.777;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;162;-2226.586,-4583.777;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;163;-2050.586,-4583.777;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;30;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;164;-1778.586,-4583.777;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;165;-2722.586,-4599.777;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;166;-2786.586,-4439.777;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;168;-2450.586,-4391.777;Inherit;False;Property;_FadeStart;FadeStart;2;0;Create;True;0;0;0;False;0;False;50;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;167;-2290.586,-4711.778;Inherit;False;Property;_FadeDistance;FadeDistance;3;0;Create;True;0;0;0;False;0;False;10;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;169;-1361.061,-4875.23;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-1116.075,-4864.021;Inherit;False;BaseAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;622.9073,20.70041;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Faycrest/BuiltIn/FaycrestWaterShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;True;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;0;2;10;25;False;0.5;True;2;5;False;;10;False;;0;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-2009.688,532.7578;Inherit;False;98;WorldSpace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;42;-1530.705,745.2962;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1.1,1.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;33;-1532.619,484.5211;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-1766.303,634.2139;Inherit;False;103;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;34;-1751.859,737.0708;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;2.4,2.4;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-1755.601,848.6119;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1.12;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-2024.601,650.6119;Inherit;False;Property;_NormalSpeed;NormalSpeed;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;4;-1932.172,1328.989;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;8.4,8.4;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;21;-1923.975,1437.62;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;29.7,29.7;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;16;-1677.221,1332.566;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;22;-1673.296,1538.915;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-940.432,1745.359;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;20.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-1101.653,1309.966;Inherit;True;Property;_WaveTexture;WaveTexture;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-1093.998,1521.763;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-934.3978,1857.466;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;4.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-740.9846,1419.193;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-746.7717,1624.842;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-520.9406,1591.085;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-2234.765,1385.146;Inherit;False;98;WorldSpace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1991.839,1539.601;Inherit;False;103;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-1398.341,1122.991;Inherit;True;Property;_WaterWaveTexture;WaterWaveTexture;6;0;Create;True;0;0;0;False;0;False;None;24e6ebb55764405439bd41534bac4497;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-717.4266,1298.42;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-524.7839,1312.757;Inherit;False;Heightmap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;52;-4537.548,-303.8487;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;41;-4296.861,-285.0931;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-4105.655,-286.1182;Inherit;False;WorldSpace;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-4155.771,141.5939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-3974.41,139.4891;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;8;-4417.368,115.8261;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;9;-4350.432,280.0232;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;16;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-307.1406,52.57335;Inherit;False;108;Normalmap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-234.6285,205.1492;Inherit;False;Constant;_Metallic;Metallic;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-265.4332,285.6435;Inherit;False;Constant;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;57;-2823.82,-5190.98;Inherit;False;Property;_MainColor;MainColor;0;0;Create;True;0;0;0;False;0;False;0.2882698,0.4834222,0.7735849,0;0.3021535,0.4418606,0.6603774,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;58;-2813.566,-5010.25;Inherit;False;Property;_HighlightColor;HighlightColor;1;0;Create;True;0;0;0;False;0;False;0.2882698,0.4834222,0.7735849,0;0.3287198,0.4960933,0.7830188,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-1745.155,-4838.94;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.8,0.8,0.8,1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1154.295,1757.089;Inherit;False;Property;_WaveStrength;WaveStrength;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-4607.756,279.916;Inherit;False;Property;_WaveSpeed;WaveSpeed;7;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-248.5764,1619.57;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;110;-2788.169,-447.2729;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;158;-2281.319,-655.9405;Inherit;False;Property;_RefractionClamp;RefractionClamp;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-2823.779,-701.793;Inherit;False;Property;_RefractionDepth;RefractionDepth;13;0;Create;True;0;0;0;False;0;False;0;-10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-2678.608,-261.5828;Inherit;False;Property;_RefractAmount;RefractAmount;12;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;122;-2064.953,-441.9431;Inherit;False;Global;_GrabScreen0;Grab Screen 0;11;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;143;-654.7433,-223.7633;Inherit;False;139;FinalAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;44;-1501.738,282.5064;Inherit;True;Property;_WaterNormal;WaterNormal;4;0;Create;True;0;0;0;False;0;False;None;5bc4a690d9fed214cafe1bb5bb1f6c6f;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
WireConnection;45;0;44;0
WireConnection;45;1;42;0
WireConnection;45;5;117;0
WireConnection;115;0;28;0
WireConnection;115;1;45;0
WireConnection;108;0;115;0
WireConnection;35;0;99;0
WireConnection;28;0;44;0
WireConnection;28;1;33;0
WireConnection;28;5;117;0
WireConnection;113;0;112;0
WireConnection;113;1;114;0
WireConnection;121;0;111;0
WireConnection;121;1;113;0
WireConnection;124;0;123;0
WireConnection;123;0;122;0
WireConnection;111;0;110;0
WireConnection;130;0;129;0
WireConnection;127;0;128;0
WireConnection;133;0;127;0
WireConnection;73;0;70;0
WireConnection;73;1;69;0
WireConnection;81;0;71;0
WireConnection;81;1;80;0
WireConnection;80;0;79;0
WireConnection;80;1;78;0
WireConnection;75;0;76;0
WireConnection;75;1;106;0
WireConnection;78;0;77;0
WireConnection;78;1;106;0
WireConnection;61;0;62;0
WireConnection;63;0;61;0
WireConnection;64;0;63;0
WireConnection;64;1;65;0
WireConnection;69;0;64;0
WireConnection;83;0;87;0
WireConnection;84;0;83;0
WireConnection;86;0;85;0
WireConnection;87;0;62;0
WireConnection;85;0;84;0
WireConnection;85;1;88;0
WireConnection;88;0;65;0
WireConnection;76;0;100;0
WireConnection;77;0;100;0
WireConnection;67;0;155;0
WireConnection;67;1;145;0
WireConnection;67;2;73;0
WireConnection;70;0;145;0
WireConnection;70;1;81;0
WireConnection;82;0;67;0
WireConnection;82;1;145;0
WireConnection;82;2;86;0
WireConnection;155;0;151;0
WireConnection;155;1;153;0
WireConnection;155;2;154;0
WireConnection;139;0;82;0
WireConnection;129;0;133;0
WireConnection;129;1;158;0
WireConnection;71;0;79;0
WireConnection;71;1;75;0
WireConnection;59;0;57;0
WireConnection;59;1;58;0
WireConnection;59;2;97;0
WireConnection;161;0;165;0
WireConnection;161;1;166;0
WireConnection;162;0;161;0
WireConnection;162;1;168;0
WireConnection;163;0;162;0
WireConnection;163;2;167;0
WireConnection;164;0;163;0
WireConnection;164;1;167;0
WireConnection;169;0;59;0
WireConnection;169;1;170;0
WireConnection;169;2;164;0
WireConnection;92;0;169;0
WireConnection;0;0;143;0
WireConnection;0;1;109;0
WireConnection;0;3;48;0
WireConnection;0;4;26;0
WireConnection;0;11;11;0
WireConnection;42;0;34;0
WireConnection;42;2;182;0
WireConnection;42;1;105;0
WireConnection;33;0;35;0
WireConnection;33;2;181;0
WireConnection;33;1;105;0
WireConnection;34;0;99;0
WireConnection;182;0;181;0
WireConnection;4;0;101;0
WireConnection;21;0;101;0
WireConnection;16;0;4;0
WireConnection;16;1;104;0
WireConnection;22;0;21;0
WireConnection;22;1;104;0
WireConnection;24;0;14;0
WireConnection;17;0;19;0
WireConnection;17;1;16;0
WireConnection;20;0;19;0
WireConnection;20;1;22;0
WireConnection;15;0;14;0
WireConnection;13;0;17;0
WireConnection;13;1;24;0
WireConnection;23;0;20;0
WireConnection;23;1;15;0
WireConnection;60;0;13;0
WireConnection;60;1;23;0
WireConnection;159;0;17;0
WireConnection;159;1;20;0
WireConnection;95;0;159;0
WireConnection;41;0;52;1
WireConnection;41;1;52;3
WireConnection;98;0;41;0
WireConnection;7;0;8;2
WireConnection;7;1;9;0
WireConnection;103;0;7;0
WireConnection;9;0;10;0
WireConnection;170;0;59;0
WireConnection;11;1;60;0
WireConnection;122;0;121;0
ASEEND*/
//CHKSM=E3746945197034C4D6942903098F903293BC88E2