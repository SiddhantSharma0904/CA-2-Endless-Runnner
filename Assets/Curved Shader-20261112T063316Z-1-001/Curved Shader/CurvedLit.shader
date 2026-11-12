Shader "Universal Render Pipeline/CurvedLit"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        [MainColor]   _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.5
        [Toggle(_METALLICSPECGLOSSMAP)] _UseMetallicMap ("Use Metallic Smoothness Map", Float) = 0.0
        _MetallicGlossMap ("Metallic (R) Smoothness (A) Map", 2D) = "white" {}

        [Toggle(_NORMALMAP)] _UseNormalMap ("Use Normal Map", Float) = 0.0
        [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Float) = 1.0

        [NoScaleOffset] _OcclusionMap ("Occlusion Map (G)", 2D) = "white" {}
        _OcclusionStrength ("Occlusion Strength", Range(0.0, 1.0)) = 1.0

        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset] _EmissionMap ("Emission Map", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
        }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _METALLICSPECGLOSSMAP

            #include "CurvedLitCode.hlsl"
            ENDHLSL
        }
    }
}