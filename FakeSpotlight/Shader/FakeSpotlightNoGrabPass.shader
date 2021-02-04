// I don't know what I'm doing pls be gentle

Shader "Temporal/FakeSpotlightNoGrabPass" {

    Properties {
        _Color("Light Color/Strength", Color) = (1,1,1,1)
        [Space(25)] _LightAngle ("Light Angle Override", range(0, 10)) = 0
        _LightDistance ("Light Distance Override", range(0,50)) = 1
        [Space(25)] _Stencil ("Stencil ID", Float) = 178
    }

    SubShader {

        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" }

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
            Blend DstColor One  

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

            float4 _Color;

            float _LightAngle;
            float _LightDistance;

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

                return fixed4(_Color.rgb, 1);
            
            }

            ENDCG
        }
    }
}
