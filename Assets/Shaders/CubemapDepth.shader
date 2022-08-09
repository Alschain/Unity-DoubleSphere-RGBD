Shader "Custom/CubemapDepth"
{
	Properties
	{
	}

	Subshader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 vertexView : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexView = UnityObjectToViewPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return float4(abs(i.vertexView.x), abs(i.vertexView.y), abs(i.vertexView.z), abs(i.vertexView.z));
			}
			ENDCG
		}
	}
}
