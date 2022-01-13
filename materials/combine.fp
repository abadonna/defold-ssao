varying mediump vec2 var_texcoord0;
uniform sampler2D tex0;
uniform sampler2D tex1;

void main()
{
	vec4 color1 = texture2D(tex0, var_texcoord0);
	vec4 color2 = texture2D(tex1, var_texcoord0);
	
	gl_FragColor = (color2 + color1) * 0.5;
}