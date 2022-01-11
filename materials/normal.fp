varying mediump vec3 var_normal;

void main()
{
    vec3 rgb_normal = var_normal.xyz * 0.5 + 0.5;
    gl_FragColor = vec4(rgb_normal, 1.);
}

