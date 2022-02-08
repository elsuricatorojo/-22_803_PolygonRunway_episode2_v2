uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;

varying float vHeight;

void main(){

    float mixStrength = (vHeight*7. + uColorOffset) * uColorMultiplier;
    vec3 color = mix(uDepthColor, uSurfaceColor, mixStrength);

    gl_FragColor = vec4(color, 0.9);
}