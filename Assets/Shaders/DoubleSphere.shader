 // Copyright Massachusetts Institute of Technology 2018

Shader "Custom/DoubleSphere"
 {

    Properties
    {
        _ColorCube ("Reflection Map, RGB", Cube) = "" {}
        _DepthCube ("Reflection Map, Depth", Cube) = "" {}
        _Alpha ("Double Sphere Alpha", float) = 2.0
        _Chi ("Double Sphere Chi", float) = 2.0
        _fx ("Double Sphere Focal Length x", float) = 1.0
        _fy ("Double Sphere Focal Length y", float) = 1.0
        _Resolution ("Image resolution", float) = 1.0
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"

            uniform samplerCUBE _ColorCube;
            uniform samplerCUBE _DepthCube;
            uniform float _Alpha;
            uniform float _Chi;
            uniform float _fx;
            uniform float _fy;
            uniform float _Resolution;

            struct v2f {
                float2 uv : TEXCOORD2;
                float4 pos : SV_POSITION;
            };



            v2f vert (float4 vertex : POSITION, float3 normal : NORMAL, float2 uv : TEXCOORD0)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, uv);
                return o;
            }

            // The Double Sphere Camera Model (V. Usenko, N. Demmel, 
            // D. Cremers), In Proc. of the Int. Conference on 3D 
            // Vision (3DV), 2018

            fixed4 frag (v2f i) : SV_Target
            {
                float cx = 0.5 * _Resolution;
                float cy = 0.5 * _Resolution;
                float fx = _fx;
                float fy = _fy;
                float alpha = _Alpha;
                float chi = _Chi;

                // Naive interpolation for cubemap adjacent lines.
                if (abs(i.uv.x+i.uv.y-1)<0.0001 || abs(i.uv.x * _Resolution - i.uv.y * _Resolution)<0.0001)
                {
                    float mx = (i.uv.x * _Resolution - cx) / fx;
                    float mx_l = (i.uv.x * _Resolution - cx - 1) / fx;
                    float mx_r = (i.uv.x * _Resolution - cx + 1) / fx;

                    float my = (i.uv.y * _Resolution - cy) / fy;

                    float r2 = mx * mx + my * my;
                    float r2_l = mx_l * mx_l + my * my;
                    float r2_r = mx_r * mx_r + my * my;

                    float beta1 = 1 - (2 * alpha - 1) * r2;
                    float beta1_l = 1 - (2 * alpha - 1) * r2_l;
                    float beta1_r = 1 - (2 * alpha - 1) * r2_r;

                    if(beta1 < 0 || beta1_l < 0 || beta1_r < 0)
                    {
                        return float4(0, 0, 0, 1);
                    } 

                    float mz = (1 - alpha * alpha * r2) / (alpha * sqrt(beta1) + 1 - alpha);
                    float mz_l = (1 - alpha * alpha * r2_l) / (alpha * sqrt(beta1_l) + 1 - alpha);
                    float mz_r = (1 - alpha * alpha * r2_r) / (alpha * sqrt(beta1_r) + 1 - alpha);

                    float beta2 = mz * mz + (1 - chi * chi) * r2;
                    float beta2_l = mz_l * mz_l + (1 - chi * chi) * r2_l;
                    float beta2_r = mz_r * mz_r + (1 - chi * chi) * r2_r;

                    if(beta2 < 0 || beta2_l < 0 || beta2_r < 0)
                    {
                        return float4(0, 0, 0, 1);
                    }

                    float3 fisheye_ray = (mz * chi + sqrt(mz * mz + (1 - chi * chi) * r2)) / (mz * mz + r2) * float3(mx, my, mz) - float3(0, 0, chi);
                    float3 fisheye_ray_l = (mz_l * chi + sqrt(mz_l * mz_l + (1 - chi * chi) * r2_l)) / (mz_l * mz_l + r2_l) * float3(mx_l, my, mz_l) - float3(0, 0, chi);
                    float3 fisheye_ray_r = (mz_r * chi + sqrt(mz_r * mz_r + (1 - chi * chi) * r2_r)) / (mz_r * mz_r + r2_r) * float3(mx_r, my, mz_r) - float3(0, 0, chi);

                    float4 rgba = texCUBE(_ColorCube, normalize(fisheye_ray));

                    float4 depth_l = texCUBE(_DepthCube, normalize(fisheye_ray_l));
                    float4 depth_r = texCUBE(_DepthCube, normalize(fisheye_ray_r));

                    float3 actray = normalize(fisheye_ray_l);

                    actray = abs(actray);
                    if (actray.x >= actray.y && actray.x >= actray.z) {rgba.a = depth_l.r;}
                    if (actray.y >= actray.x && actray.y >= actray.z) {rgba.a = depth_l.g;}
                    if (actray.z >= actray.x && actray.z >= actray.y) {rgba.a = depth_l.b;}

                    actray = normalize(fisheye_ray_r);

                    actray = abs(actray);
                    if (actray.x >= actray.y && actray.x >= actray.z) {rgba.a = (rgba.a + depth_r.r) / 2.0;}
                    if (actray.y >= actray.x && actray.y >= actray.z) {rgba.a = (rgba.a + depth_r.g) / 2.0;}
                    if (actray.z >= actray.x && actray.z >= actray.y) {rgba.a = (rgba.a + depth_r.b) / 2.0;}
                    return rgba;
                }

                float mx = (i.uv.x * _Resolution - cx) / fx;
                float my = (i.uv.y * _Resolution - cy) / fy;

                float r2 = mx * mx + my * my;
                float beta1 = 1 - (2 * alpha - 1) * r2;
                if(beta1 < 0)
                {
                    return float4(0, 0, 0, 1);
                } 
                float mz = (1 - alpha * alpha * r2) / (alpha * sqrt(beta1) + 1 - alpha);

                float beta2 = mz * mz + (1 - chi * chi) * r2;

                if(beta2 < 0)
                {
                    return float4(0, 0, 0, 1);
                }

                float3 fisheye_ray = (mz * chi + sqrt(mz * mz + (1 - chi * chi) * r2)) / (mz * mz + r2) * float3(mx, my, mz) - float3(0, 0, chi);

                float3 actray =normalize(fisheye_ray);
                float4 rgba = texCUBE(_ColorCube, actray);
                float4 depth = texCUBE(_DepthCube, actray);

                // Due to the render method by cubemap, we need to find correct axis for calculating depth
                // We get depth by judging which axis the ray is, for different face we should retarget the depth from correct axis
                // In cubemap depth shader, we store negative with abs and wr only fetch the front view so no worry about neg depth
                actray = abs(actray);
                if (actray.x >= actray.y && actray.x >= actray.z) {rgba.a = depth.r;}
                if (actray.y >= actray.x && actray.y >= actray.z) {rgba.a = depth.g;}
                if (actray.z >= actray.x && actray.z >= actray.y) {rgba.a = depth.b;}

                // rgba.a = depth.r;
                return rgba;
            }
            ENDCG
        }
    }
}