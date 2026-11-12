#ifndef CURVED_LIT_CODE_INCLUDED
#define CURVED_LIT_CODE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
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
    float4 vertex  : POSITION;
    float3 normal  : NORMAL;
    float4 tangent : TANGENT;
    float2 uv      : TEXCOORD0;
    half4  color   : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float2 uv         : TEXCOORD0;
    half   fogFactor  : TEXCOORD1;
    half4  color      : TEXCOORD2;
    float3 positionWS : TEXCOORD3;
    float3 normalWS   : TEXCOORD4;
    #if defined(_NORMALMAP)
    float4 tangentWS  : TEXCOORD5;
    #endif
    float4 vertex     : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

TEXTURE2D(_MetallicGlossMap);
SAMPLER(sampler_MetallicGlossMap);

TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);

TEXTURE2D(_OcclusionMap);
SAMPLER(sampler_OcclusionMap);

TEXTURE2D(_EmissionMap);
SAMPLER(sampler_EmissionMap);

// Set globally by WorldCurver.cs
float _CurveStrength;

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half4  _BaseColor;
    half   _Metallic;
    half   _Smoothness;
    half   _BumpScale;
    half   _OcclusionStrength;
    half4  _EmissionColor;
CBUFFER_END

v2f vert(appdata v)
{
    v2f o = (v2f)0;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    VertexPositionInputs posInputs = GetVertexPositionInputs(v.vertex.xyz);
    VertexNormalInputs normInputs = GetVertexNormalInputs(v.normal, v.tangent);

    o.vertex = posInputs.positionCS;

    float dist = UNITY_Z_0_FAR_FROM_CLIPSPACE(o.vertex.z);
    o.vertex.y -= _CurveStrength * dist * dist * _ProjectionParams.x;

    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.color = v.color;
    o.positionWS = posInputs.positionWS;
    o.normalWS = normInputs.normalWS;

    #if defined(_NORMALMAP)
    real sign = v.tangent.w * GetOddNegativeScale();
    o.tangentWS = float4(normInputs.tangentWS.xyz, sign);
    #endif

    o.fogFactor = ComputeFogFactor(o.vertex.z);

    return o;
}

half4 frag(v2f i) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _BaseColor * i.color;

    half metallic = _Metallic;
    half smoothness = _Smoothness;
    #if defined(_METALLICSPECGLOSSMAP)
        half4 metallicGloss = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, i.uv);
        metallic = metallicGloss.r * _Metallic;
        smoothness = metallicGloss.a * _Smoothness;
    #endif

    half3 normalTS = half3(0.0h, 0.0h, 1.0h);
    float3 normalWS = i.normalWS;
    #if defined(_NORMALMAP)
        normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv), _BumpScale);
        float sgn = i.tangentWS.w;
        float3 bitangent = sgn * cross(i.normalWS.xyz, i.tangentWS.xyz);
        normalWS = TransformTangentToWorld(normalTS, half3x3(i.tangentWS.xyz, bitangent.xyz, i.normalWS.xyz));
    #endif
    normalWS = NormalizeNormalPerPixel(normalWS);

    half occSample = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, i.uv).g;
    half occlusion = LerpWhiteTo(occSample, _OcclusionStrength);
    half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, i.uv).rgb * _EmissionColor.rgb;

    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = col.rgb;
    surfaceData.alpha = col.a;
    surfaceData.metallic = metallic;
    surfaceData.specular = half3(0.0h, 0.0h, 0.0h);
    surfaceData.smoothness = smoothness;
    surfaceData.normalTS = normalTS;
    surfaceData.occlusion = occlusion;
    surfaceData.emission = emission;

    InputData inputData = (InputData)0;
    inputData.positionWS = i.positionWS;
    inputData.normalWS = normalWS;
    inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(i.positionWS);
    inputData.shadowCoord = TransformWorldToShadowCoord(i.positionWS);
    inputData.fogCoord = i.fogFactor;
    inputData.bakedGI = SampleSH(normalWS);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(i.vertex);
    inputData.shadowMask = half4(1, 1, 1, 1);

    half4 finalColor = UniversalFragmentPBR(inputData, surfaceData);
    finalColor.rgb = MixFog(finalColor.rgb, inputData.fogCoord);

    return finalColor;
}

#endif