// Mixes color with luma-coefficient grayscale
vec3 colorMix(vec3 color, float time) {
    float gray = dot(color, vec3(0.2126, 0.7152, 0.0722));
    return mix(vec3(gray), color, time);
}

// Main
void main(void) {
//    float time = fract(u_time/u_duration);
//    
//    vec4 texture = texture2D(u_texture, v_tex_coord);
//    
//    // Mixed color
//    vec3 color = colorMix(texture.rgb, time);
//    
//    float num = sin(360.0*(1.0-time))*256.0;
//    float line = floor(num*v_tex_coord.y);
//    float bin = mod(line, 2.0);
//    
//    vec4 almost = mix(vec4(color, texture.a)*time, texture*vec4(bin), bin);
//    
//    if (almost.a <= 0.2) {
//        almost.a = 0.0;
//    }
//    
//    gl_FragColor = vec4(almost.rgb + vec3(0,(1.0-time)*0.25,(1.0-time)*0.5) * almost.a, almost.a);
    
    sampler2D u_texture =
    float time = u_time * .5;
    vec2 sp = gl_FragCoord.xy / size.xy;
    vec2 p = sp * 6.0 - 20.0;
    vec2 i = p;
    float c = 1.0;
    float inten = .05;
    
    for (int n = 0; n < 5; n++)
    {
        float t = time * (1.0 - (3.5 / float(n+1)));
        i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
        c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
    }
    
    c /= float(5);
    c = 1.55-sqrt(c);
    vec3 colour = vec3(pow(abs(c), 15.0));
    
    gl_FragColor = vec4(clamp(colour + vec3(0.0, 0.17, 0.3), 0.0, .5), 0.3);
}
