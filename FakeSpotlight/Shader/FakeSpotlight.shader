Shader "Temporal/FakeSpotlight" {
    
    Properties {
        _Color("Color Tint", Color) = (1,1,1,1)
        _LightAngle ("Light Angle Override", range(0, 10)) = 0
        _LightDistance ("Light Distance Override", range(0,50)) = 1
        [Toggle] _DarkLight("Dark Light", Float) = 0
        _Brightness ("Brightness", Range(0,1)) = 0
        _BrightnessMultiplier ("Brightness Multiplier", Range(1,20)) = 1
        _Hue("Hue Shift", Range(-180,180)) = 0
        _Saturation ("Saturation", Range(0,2)) = 1
        _Contrast ("Contrast", Range(0.5,1.5)) = 1
        _Temperature ("White Balance (Temperature)", Range(-0.5,0.5)) = 0
        _Tint("White Balance (Tint)", Range(-0.5,0.5)) = 0
        _Stencil ("Stencil ID", Float) = 178
    }

    SubShader {

        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" }

        GrabPass { "_GrabFakeLight" }
        LOD 100

        Pass {

            ZTest LEqual
            Cull Back
            ColorMask 0
            ZWrite Off
            Lighting Off

            Stencil {
                Ref [_Stencil]
                Comp Always
                WriteMask [_Stencil]
                ZFail Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            float _LightAngle;
            float _LightDistance;
            
            v2f vert (appdata v) {
                v2f o;

                v.vertex.y *= _LightDistance;
                v.vertex.xz *= v.vertex.y * exp(_LightAngle);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeScreenPos(o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {
                return 0;
            }
            ENDCG
        }

        Pass {

            ZTest Greater
            Cull Front
            ZWrite Off
            Lighting Off
            AlphaToMask On
            Blend SrcAlpha OneMinusSrcAlpha

            Stencil {
                Ref [_Stencil]
                Comp NotEqual
                ReadMask [_Stencil]
                WriteMask [_Stencil]
                Pass Replace
                Fail Zero
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            sampler2D _GrabFakeLight;
            float4 _GrabFakeLight_ST;

            float4 _Color;
            float _Brightness;
            float _BrightnessMultiplier;
            float _Hue;
            float _Saturation;
            float _Temperature;
            float _Tint;
            float _Contrast;

            float _LightAngle;
            float _LightDistance;
            float _DarkLight;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 Unity_Hue_Degrees_float(float3 In, float Offset)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                float D = Q.x - min(Q.w, Q.y);
                float E = 1e-10;
                float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), Q.x);

                float hue = hsv.x + Offset / 360;
                hsv.x = (hue < 0)
                        ? hue + 1
                        : (hue > 1)
                            ? hue - 1
                            : hue;

                float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                return hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
            }

            float3 Unity_Saturation_float(float3 In, float Saturation)
            {
                float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
                return luma.xxx + Saturation.xxx * (In - luma.xxx);
            }

            float3 Unity_Temperature(float3 In, float Temperature, float Tint)
            {
                // Range ~[-1.67;1.67] works best
                float t1 = Temperature * 10 / 6;
                float t2 = Tint * 10 / 6;

                // Get the CIE xy chromaticity of the reference white point.
                // Note: 0.31271 = x value on the D65 white point
                float x = 0.31271 - t1 * (t1 < 0 ? 0.1 : 0.05);
                float standardIlluminantY = 2.87 * x - 3 * x * x - 0.27509507;
                float y = standardIlluminantY + t2 * 0.05;

                // Calculate the coefficients in the LMS space.
                float3 w1 = float3(0.949237, 1.03542, 1.08728); // D65 white point

                // CIExyToLMS
                float Y = 1;
                float X = Y * x / y;
                float Z = Y * (1 - x - y) / y;
                float L = 0.7328 * X + 0.4296 * Y - 0.1624 * Z;
                float M = -0.7036 * X + 1.6975 * Y + 0.0061 * Z;
                float S = 0.0030 * X + 0.0136 * Y + 0.9834 * Z;
                float3 w2 = float3(L, M, S);

                float3 balance = float3(w1.x / w2.x, w1.y / w2.y, w1.z / w2.z);

                float3x3 LIN_2_LMS_MAT = {
                    3.90405e-1, 5.49941e-1, 8.92632e-3,
                    7.08416e-2, 9.63172e-1, 1.35775e-3,
                    2.31082e-2, 1.28021e-1, 9.36245e-1
                };

                float3x3 LMS_2_LIN_MAT = {
                    2.85847e+0, -1.62879e+0, -2.48910e-2,
                    -2.10182e-1,  1.15820e+0,  3.24281e-4,
                    -4.18120e-2, -1.18169e-1,  1.06867e+0
                };

                float3 lms = mul(LIN_2_LMS_MAT, In);
                lms *= balance;
                return mul(LMS_2_LIN_MAT, lms);
            }

            float3 Unity_Contrast_float(float3 In, float Contrast)
            {
                float midpoint = pow(0.5, 2.2);
                return (In - midpoint) * Contrast + midpoint;
            }
            
            v2f vert (appdata v) {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                v.vertex.y *= _LightDistance;
                v.vertex.xz *= v.vertex.y * exp(_LightAngle);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeScreenPos(o.pos);
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {
            
                float4 col = tex2D(_GrabFakeLight, (i.uv.xy/i.uv.w));   
                col.a = 1;

                col.rgb *= _Color.rgb;
                col.rgb = Unity_Hue_Degrees_float(col.rgb, _Hue);
                col.rgb = Unity_Saturation_float(col.rgb, _Saturation);
                col.rgb = Unity_Temperature(col.rgb, _Temperature, _Tint);
                col.rgb = Unity_Contrast_float(col.rgb, _Contrast);

                if (_DarkLight) {
                    col.rgb *= 1 - _Brightness;
                } else {
                    col.rgb *= (_Brightness * _BrightnessMultiplier) + 1;
                }

                return col;
            }
            ENDCG
        }
    }
}
