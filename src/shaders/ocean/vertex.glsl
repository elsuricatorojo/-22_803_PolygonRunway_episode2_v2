uniform float uTime;
uniform float uHeight;

varying float vHeight;




//------------------------------------
//------------------------------------
//------------------------------------
#define gln_PI 3.1415926538
#define MAX_FBM_ITERATIONS 30

struct gln_tFBMOpts {
    /**
    * @typedef {struct} gln_tFBMOpts   Options for fBm generators.
    * @property {float} seed           Seed for PRNG generation.
    * @property {float} persistance    Factor by which successive layers of noise
    * will decrease in amplitude.
    * @property {float} lacunarity     Factor by which successive layers of noise
    * will increase in frequency.
    * @property {float} scale          "Zoom level" of generated noise.
    * @property {float} redistribution Flatness in the generated noise.
    * @property {int} octaves          Number of layers of noise to stack.
    * @property {boolean} terbulance   Enable terbulance
    * @property {boolean} ridge        Convert the fBm to Ridge Noise. Only works
    * when "terbulance" is set to true.
    */
    float seed;
    float persistance;
    float lacunarity;
    float scale;
    float redistribution;
    int octaves;
    bool terbulance;
    bool ridge;
};



vec2 _fade2(vec2 t) { // ROBERTO +
//vec2 _fade(vec2 t) { // ROBERTO -
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

vec4 gln_rand4(vec4 p) {
    /**
    * Generates a random 4D Vector.
    *
    * @name gln_rand4
    * @function
    * @param {vec4} p Vector to hash to generate the random numbers from.
    * @return {vec4} Random vector.
    *
    * @example
    * vec4 n = gln_rand4(vec4(1.0, -4.2, 0.2, 2.2));
    */
    return mod(((p * 34.0) + 1.0) * p, 289.0);    
}

float gln_map(float value, float min1, float max1, float min2, float max2) {
    /**
    * Converts a number from one range to another.
    *
    * @name gln_map
    * @function
    * @param {} value      Value to map
    * @param {float} min1  Minimum for current range
    * @param {float} max1  Maximum for current range
    * @param {float} min2  Minimum for wanted range
    * @param {float} max2  Maximum for wanted range
    * @return {float} Mapped Value
    *
    * @example
    * float n = gln_map(-0.2, -1.0, 1.0, 0.0, 1.0);
    * // n = 0.4
    */
    return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float gln_normalize(float v) {
    /**
    * Normalized a value from the range [-1, 1] to the range [0,1].
    *
    * @name gln_normalize
    * @function
    * @param {float} v Value to normalize
    * @return {float} Normalized Value
    *
    * @example
    * float n = gln_normalize(-0.2);
    * // n = 0.4
    */
    return gln_map(v, -1.0, 1.0, 0.0, 1.0);
}

float gln_perlin(vec2 P) {
    /**
    * Generates 2D Perlin Noise.
    *
    * @name gln_perlin
    * @function
    * @param {vec2} p  Point to sample Perlin Noise at.
    * @return {float}  Value of Perlin Noise at point "p".
    *
    * @example
    * float n = gln_perlin(position.xy);
    */
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    vec4 i = gln_rand4(gln_rand4(ix) + iy);
    vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
    vec4 gy = abs(gx) - 0.5;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    vec2 g00 = vec2(gx.x, gy.x);
    vec2 g10 = vec2(gx.y, gy.y);
    vec2 g01 = vec2(gx.z, gy.z);
    vec2 g11 = vec2(gx.w, gy.w);
    vec4 norm = 1.79284291400159 - 0.85373472095314 * vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    vec2 fade_xy = _fade2(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

float gln_pfbm2(vec2 p, gln_tFBMOpts opts) { // ROBERTO +
// float gln_pfbm(vec2 p, gln_tFBMOpts opts) { // ROBERTO -
    /**
    * Generates 2D Fractional Brownian motion (fBm) from Perlin Noise.
    *
    * @name gln_pfbm
    * @function
    * @param {vec2} p               Point to sample fBm at.
    * @param {gln_tFBMOpts} opts    Options for generating Perlin Noise.
    * @return {float}               Value of fBm at point "p".
    *
    * @example
    * gln_tFBMOpts opts =
    *      gln_tFBMOpts(uSeed, 0.3, 2.0, 0.5, 1.0, 5, false, false);
    *
    * float n = gln_pfbm(position.xy, opts);
    */
    p += (opts.seed * 100.0);
    float persistance = opts.persistance;
    float lacunarity = opts.lacunarity;
    float redistribution = opts.redistribution;
    int octaves = opts.octaves;
    bool terbulance = opts.terbulance;
    bool ridge = opts.terbulance && opts.ridge;

    float result = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    float maximum = amplitude;

    for (int i = 0; i < MAX_FBM_ITERATIONS; i++) {
        if (i >= octaves)
        break;

        vec2 p = p * frequency * opts.scale;

        float noiseVal = gln_perlin(p);

        if (terbulance)
        noiseVal = abs(noiseVal);

        if (ridge)
        noiseVal = -1.0 * noiseVal;

        result += noiseVal * amplitude;

        frequency *= lacunarity;
        amplitude *= persistance;
        maximum += amplitude;
    }

    float redistributed = pow(result, redistribution);
    return redistributed / maximum;
}


struct gln_tGerstnerWaveOpts {
    /**
    * @typedef {struct} gln_tGerstnerWaveOpts   Options for Gerstner Wave
    * generators.
    * @property {vec2} direction               Direction of the wave
    * @property {float} steepness              Steepness of the peeks
    * @property {float} wavelength             Wavelength of the waves
    */
    vec2 direction;
    float steepness;
    float wavelength;
};

vec3 gln_GerstnerWave(vec3 p, gln_tGerstnerWaveOpts opts, float dt) {
    /**
    * Implimentation of Gerstner Wave
    * Based on: https://catlikecoding.com/unity/tutorials/flow/waves/
    *
    * @name gln_GerstnerWave
    * @function
    * @param {vec3} p Point to sample Gerstner Waves at.
    * @param {gln_tGerstnerWaveOpts} opts
    * @param {float} dt
    *
    * @example
    * float n = gln_perlin(position.xy);
    */
    float steepness = opts.steepness;
    float wavelength = opts.wavelength;
    float k = 2.0 * gln_PI / wavelength;
    float c = sqrt(9.8 / k);
    vec2 d = normalize(opts.direction);
    float f = k * (dot(d, p.xy) - c * dt);
    float a = steepness / k;

    return vec3(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)));
}
//------------------------------------
//------------------------------------
//------------------------------------

vec3 displace(vec3 point) {

    vec3 p = point;


        //p.y += uTime * 0.1;
        

        //gln_tFBMOpts fbmOpts = gln_tFBMOpts(1.0, 0.4, 2.3, 0.4, 1.0, 5, false, false);
        gln_tFBMOpts fbmOpts = gln_tFBMOpts(1.0, 0.4, 2.3, 0.2, 1.0, 5, false, false);

        float frecMod = 2.;
    
        gln_tGerstnerWaveOpts A = gln_tGerstnerWaveOpts(vec2(0.0, -1.0), 0.2, 2.0/frecMod);
        gln_tGerstnerWaveOpts B = gln_tGerstnerWaveOpts(vec2(0.5, -1.0), 0.25, 4.0/frecMod);
        gln_tGerstnerWaveOpts C = gln_tGerstnerWaveOpts(vec2(1.0, -1.0), 0.15, 6.0/frecMod);
        gln_tGerstnerWaveOpts D = gln_tGerstnerWaveOpts(vec2(1.0, 1.0), 0.25, 2.0/frecMod);
        
       /*
        gln_tGerstnerWaveOpts A = gln_tGerstnerWaveOpts(vec2(0.0, -1.0), 0.5/1., 1.0);
        gln_tGerstnerWaveOpts B = gln_tGerstnerWaveOpts(vec2(0.0, 1.0), 0.25/1., 2.0);
        gln_tGerstnerWaveOpts C = gln_tGerstnerWaveOpts(vec2(1.0, 1.0), 0.15/1., 3.0);
        gln_tGerstnerWaveOpts D = gln_tGerstnerWaveOpts(vec2(1.0, 1.0), 0.4/1., 1.0);
*/
        vec3 n = vec3(0.0);

        //if(p.z >= uHeight / 2.0) {
            //n.z += gln_normalize(gln_pfbm2(p.xy + (uTime * 0.5), fbmOpts));
            //n.z += gln_normalize(gln_pfbm2(p.xy + (uTime * 0.5), 1));
            n.z += 0.5;
            n += gln_GerstnerWave(p, A, uTime).xzy;
            n += gln_GerstnerWave(p, B, uTime).xzy * 0.5;
            n += gln_GerstnerWave(p, C, uTime).xzy * 0.25;
            n += gln_GerstnerWave(p, D, uTime).xzy * 0.2;
            n.y = 0.;
            n.x = 0.;
        //}
        

        vHeight = n.z;

        vec3 result = point;
        if(point.z > 3.){ // BORRAR AQUI PARA QUE EL EFECTO SEA A TODO EL PLANO
            result = point + n;
        }
        return result;


}  


void main() {
    

    /*
    position.x += displacedPosition.x;
    position.y += displacedPosition.y;
    position.z += displacedPosition.z;
    */


    vec3 displacedPosition = displace(position.xyz); 
    vec4 modelPosition = modelMatrix * vec4(displacedPosition, 1.0); 

    

    vec4 viewPosition = viewMatrix * modelPosition;


    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;
    

}