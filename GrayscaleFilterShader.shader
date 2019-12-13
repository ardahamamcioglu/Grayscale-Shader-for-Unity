Shader "Unlit/GrayscaleFilterShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RedFilter ("Grayscale Red Filter", Range(0,1)) = 1.0
		_GreenFilter ("Grayscale Green Filter", Range(0,1)) = 1.0
		_BlueFilter ("Grayscale Blue Filter", Range(0,1)) = 1.0
	}
	SubShader
	{
		Tags { "Queue"="Transparent"}
		GrabPass{}
		Pass
		{
			CGPROGRAM
			#pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 uvgrab :TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize,_MainTex_ST;
			sampler2D _GrabTexture;

			fixed _RedFilter,_GreenFilter,_BlueFilter;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed4 vertexUv = o.vertex;
				
				//Platform specific UV transformation
				#if UNITY_UV_STARTS_AT_TOP
					vertexUv.y *= -sign(_MainTex_TexelSize.y);
				#endif
				
				o.uvgrab.xy = (float2(vertexUv.x,vertexUv.y) + vertexUv.w) * 0.5;
				o.uvgrab.zw = vertexUv.zw;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// sample the grabPass
				fixed4 grab = tex2Dproj(_GrabTexture, i.uvgrab);
				//Grayscale
				fixed range = max(0.0001,_RedFilter + _GreenFilter + _BlueFilter);
				grab.rgb = (grab.r*_RedFilter + grab.g * _GreenFilter + grab.b * _BlueFilter) / range;

				return grab;
			}
			ENDCG
		}
	}
}