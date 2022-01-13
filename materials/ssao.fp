varying mediump vec2 var_texcoord0;
varying mediump vec3 var_view_ray;
varying mediump mat4 var_mtx;

uniform sampler2D tex0;
uniform highp sampler2D tex1;
uniform highp sampler2D tex2;

uniform highp vec4 kernel[64];
uniform highp vec4 noise[16];
uniform mediump mat4 mtx_proj;

float rgba_to_float(vec4 rgba)
{
	return dot(rgba, vec4(1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0));
}

float far = 20.;
float near = .1;
float fov = 0.7854;
float aspect = 1.5;

vec3 unproject1(vec2 uv) //version 1 - using similar triangles
{
	//calculate R,T on CPU, here for simplicity
	float T = near * tan(0.5 * fov); 
	float R = aspect * T; 

	float d = rgba_to_float(texture2D(tex1, uv));
	vec2 ndc = uv * 2.0 - 1.0;
	vec2 pnear = ndc * vec2(R,T);
	float pz = -d * far;
	return vec3(-pz * pnear.x / near, -pz * pnear.y / near, pz);
}

vec3 unproject2(vec2 uv) //version 2 - with inversed projection matrix
{
	vec2 ndc = uv * 2.0 - 1.0;
	vec3 view_ray = (var_mtx * vec4(ndc, 1.0, 1.0)).xyz;
	//pass view_ray from vertex shader instead - see unproject3
	
	float d = rgba_to_float(texture2D(tex1, uv));
	return d * far * view_ray;
}

vec3 unproject3(vec2 uv) //same approach as v2, 
{
	float d = rgba_to_float(texture2D(tex1, uv));
	return var_view_ray * d;
}


void main()
{
	vec4 data = texture2D(tex0, var_texcoord0);
	vec3 normal = data.xyz * 2.0 - 1.0;
	normal = normalize(normal);

	//vec3 origin = unproject1(var_texcoord0);
	//vec3 origin = unproject2(var_texcoord0);
	vec3 origin = unproject3(var_texcoord0);

	ivec2 ts = textureSize(tex0, 0);
	int u = int(mod(var_texcoord0.x  * ts.x,  4));
	int v = int(mod(var_texcoord0.y * ts.y, 4));
	
	vec3 rvec = noise[u*4 + v].xyz;
	vec3 tangent = normalize(rvec - normal * dot(rvec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 tbn = mat3(tangent, bitangent, normal);

	float bias = 0.;
	float radius = .8;
	float occlusion = 0.0;
	
	for (int i = 0; i < 64; ++i) {
		// get sample position:
		vec3 sample = tbn * kernel[i].xyz;
		sample = sample * radius + origin;

		// project sample position:
		vec4 offset = vec4(sample, 1.0);
		offset = mtx_proj * offset;
		offset.xy /= offset.w;
		offset.xy = offset.xy * 0.5 + 0.5;

		// get sample depth:
		float depth = - rgba_to_float(texture2D(tex1, offset.xy)) * far;
		
		// range check & accumulate:
		float check = smoothstep(0.0, 1.0, radius / abs(origin.z - depth));
		occlusion += (depth >= sample.z + bias ? 1.0 : 0.0) * check;
	}

	occlusion = 1.- (occlusion / 64.);
	
	gl_FragColor = vec4(occlusion,occlusion,occlusion, 1); 

	//gl_FragColor = vec4(vec3(rgba_to_float(texture(tex1, var_texcoord0))), 1); 
	
}