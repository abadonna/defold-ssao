varying mediump vec2 var_texcoord0;
uniform sampler2D tex0;
uniform sampler2D tex1;


void main()
{
	vec2 texel = 1.0 / vec2(textureSize(tex0, 0));
	float occlusion = 0.0;
	for (int x = -2; x < 2; ++x) 
	{
		for (int y = -2; y < 2; ++y) 
		{
			vec2 offset = vec2(float(x), float(y)) * texel;
			occlusion += texture2D(tex0, var_texcoord0 + offset).x;
		}
	}
	occlusion = occlusion / 16.;
	vec4 color = texture2D(tex1, var_texcoord0);
	
	//gl_FragColor = vec4(occlusion,occlusion,occlusion, 1.);
	gl_FragColor = vec4(color.xyz * occlusion, color.w);
	//gl_FragColor = texture2D(tex0, var_texcoord0);

}