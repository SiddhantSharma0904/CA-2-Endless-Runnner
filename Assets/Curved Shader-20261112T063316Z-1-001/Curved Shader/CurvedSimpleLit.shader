Shader "Universal Render Pipeline/CurvedSimpleLit"
{
    Properties
    {
        [MainTexture] _MainTex ("Texture", 2D) = "white" {}
        [MainColor]   _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _SpecColor ("Specular Color", Color) = (0.2, 0.2, 0.2, 1.0)
        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.5
        [Toggle(_SPECULAR_COLOR)] _SpecularHighlights ("Enable Specular Highlights", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "SimpleLit"
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
            #pragma shader_feature_local _SPECULAR_COLOR

            #include "CurvedSimpleLitCode.hlsl"
            ENDHLSL
        }
    }
}