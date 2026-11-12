#ifndef CURVED_SIMPLE_LIT_CODE_INCLUDED
#define CURVED_SIMPLE_LIT_CODE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#ifndef UNITY_Z_0_FAR_FROM_CLIPSPACE
    #if defined(UNITY_REVERSED_Z)
        #define UNITY_Z_0_FAR_FROM_CLIPSPACE(coord) max(((1.0 - (coord) / _ProjectionParams.y) * _ProjectionParams.z), 0)
    #elif UNITY_UV_STARTS_AT_TOP
        #define UNITY_Z_0_FAR_FROM_CLIPSPACE(coord) (coord)
    #else
        #define UNITY_Z_0_FAR_FROM_CLIPSPACE(coord) (coord)
    #endif
#endif

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv     : TEXCOORD0;
    half4  color  : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float2 uv         : TEXCOORD0;
    half   fogFactor  : TEXCOORD1;
    half4  color      : TEXCOORD2;
    float3 positionWS : TEXCOORD3;
    float3 normalWS   : TEXCOORD4;
    float4 vertex     : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

// Set globally by WorldCurver.cs
float _CurveStrength;

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half4 _BaseColor;
    half4 _SpecColor;
    half _Smoothness;
CBUFFER_END

v2f vert(appdata v)
{
    v2f o = (v2f)0;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    VertexPositionInputs posInputs = GetVertexPositionInputs(v.vertex.xyz);
    VertexNormalInputs normInputs = GetVertexNormalInputs(v.normal);

    o.vertex = posInputs.positionCS;

    float dist = UNITY_Z_0_FAR_FROM_CLIPSPACE(o.vertex.z);
    o.vertex.y -= _CurveStrength * dist * dist * _ProjectionParams.x;

    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.color = v.color;
    o.positionWS = posInputs.positionWS;
    o.normalWS = normInputs.normalWS;
    o.fogFactor = ComputeFogFactor(o.vertex.z);

    return o;
}

half4 frag(v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _BaseColor * i.color;

    float3 normalWS = NormalizeNormalPerPixel(i.normalWS);
    float3 viewDirWS = SafeNormalize(GetCameraPositionWS() - i.positionWS);

    float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS);
    Light mainLight = GetMainLight(shadowCoord);

    half3 attenuatedLight = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
    half3 diffuse = SampleSH(normalWS) + LightingLambert(attenuatedLight, mainLight.direction, normalWS);

    half3 specular = half3(0.0h, 0.0h, 0.0h);
    #if defined(_SPECULAR_COLOR)
        half smoothness = exp2(10.0h * _Smoothness + 1.0h);
        specular += LightingSpecular(attenuatedLight, mainLight.direction, normalWS, viewDirWS, _SpecColor, smoothness);
    #endif

    #if defined(_ADDITIONAL_LIGHTS)
        uint lightCount = GetAdditionalLightsCount();
        for (uint lightIdx = 0u; lightIdx < lightCount; ++lightIdx)
        {
            Light light = GetAdditionalLight(lightIdx, i.positionWS, half4(1, 1, 1, 1));
            half3 addLight = light.color * (light.distanceAttenuation * light.shadowAttenuation);
            diffuse += LightingLambert(addLight, light.direction, normalWS);

            #if defined(_SPECULAR_COLOR)
                half smoothnessAdd = exp2(10.0h * _Smoothness + 1.0h);
                specular += LightingSpecular(addLight, light.direction, normalWS, viewDirWS, _SpecColor, smoothnessAdd);
            #endif
        }
    #endif

    col.rgb = diffuse * col.rgb + specular;
    col.rgb = MixFog(col.rgb, i.fogFactor);

    return col;
}

#endif