varying highp vec4 var_position;

vec4 float_to_rgba(float v)
{
    vec4 enc = vec4(1.0, 255.0, 65025.0, 16581375.0) * v;
    enc      = fract(enc);
    enc     -= enc.yzww * vec4(1.0/255.0,1.0/255.0,1.0/255.0,0.0);
    return enc;
}

void main()
{
    float far = 20.;
    gl_FragColor = float_to_rgba(- var_position.z / far);
}

