#include <metal_stdlib>
using namespace metal;



struct VertexIn {
    float3 position  [[attribute(0)]];
    float3 normal    [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 eyeNormal;
    float4 eyePosition;
    float2 texCoords;
};

struct Uniforms {
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
};

//positions
vertex VertexOut vertex_main(VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut vertexOut;
    vertexOut.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(vertexIn.position, 1);
    vertexOut.eyeNormal = uniforms.modelViewMatrix * float4(vertexIn.normal, 0);
    vertexOut.eyePosition = uniforms.modelViewMatrix * float4(vertexIn.position, 1);
    vertexOut.texCoords = vertexIn.texCoords;
    return vertexOut;
}
//color
fragment float4 fragment_main(VertexOut fragmentIn [[stage_in]]) {
    float3 normal = normalize(fragmentIn.eyeNormal.xyz);
    return float4(abs(normal), 1);
}

//about screen utility methods

//const float maxDist = 250.;

float3x3 rotMat(float3 ax, float a) {
    ax = normalize(ax);
    float s = sin(a), c = cos(a), oc = 1. - c;
    float2 j = oc * ax.x * ax.xy, k = oc * ax.y * ax.yz, l = oc * ax.z * ax.zx;
    return float3x3(j.x+c,j.y-s*ax.z,l.y+s*ax.y,j.y+s*ax.z,k.x+c,k.y-s*ax.x,l.y-s*ax.y,k.y+s*ax.x,l.x+c);
};

//have to implement mod myself because apple is lazy
#define textureS(s, uv) float4(0.0)
//#define R float2x2(0.0)
float2 mod(float2 x, float y)
{
    //formula: x - y * floor(x/y)
    //apple way: x - y * trunc(x/y) <----- values are off for negative values
    float2 temp = (0.);
    temp.x = x.x - y * floor(x.x/y);
    temp.y = x.y - y * floor(x.y/y);
    return temp;
};

float3 mod(float3 x, float y)
{
    float3 temp = (0.);
    temp.x = x.x - y * floor(x.x/y);
    temp.y = x.y - y * floor(x.y/y);
    temp.z = x.z - y * floor(x.z/y);
    return temp;
}

float hash(float x){
    return fract(sin(x*54265.135165416));
}

float smin(float a, float b, float k){
    float h = max(k-abs(a-b), 0.0)/k;
    return min(a, b) - h*h*h*k*(1.0/6.0);
}

// store the matrix globally so the 2D "normal map" sticks better

float map(float3 p, float time){
    // rotate
    
    float r = 3.14159*sin(p.z*0.15)+time*0.25;
    p.x = p.x*cos(r) + p.y*sin(r);
    p.y = p.x*sin(-r) + p.y*cos(r);
    float3 op = p;
    
    // repeat lattice
    const float a = 1.;
    p = mod(p, a)-a*0.5;
    
    // primitives
    // center sphere
    float v = length(p)-(0.02+(0.01*(0.6+0.4*sin(5.0*time)) ));

    v = smin(v, length(p.xz+0.01*sin(-5.0*time-8.0*(op.x-op.z)))-0.03, 0.45);
    
    return v;
}

float3 normal(float3 p, float time){
    float o = map(p,time);
    const float e = 0.001;
    return normalize( float3(map(p+float3(e,0,0),time)-o,
                           map(p+float3(0,e,0),time)-o,
                           map(p+float3(0,0,e),time)-o));
}

float3 march(float3 o, float3 dir, float time){
    float3 p = o;
    float e = 0.0;
    //compromise to increase performance
    for(int i = 0; i < 70; ++i){
        float d = 0.5*map(p,time);
        e += d;
        if(d < 0.005 || e > 12.0)
            break;
        p += d*dir;
    }
    
    return p;
}

float4 subsurface(float3 o, float3 dir,float time){
    float3 p = o;
    float e = 0.0;
    for(int i = 0; i < 7; ++i){
        float d = map(p,time);
        e += -d;
        if(d > -0.001)
            break;
        p -= d*dir;
    }
    
    return float4(p, e);
}

float G(float dotNV, float k){
    return 1.0/(dotNV*(1.0-k)+k);
}

// from http://filmicworlds.com/blog/optimizing-ggx-shaders-with-dotlh/
float ggx(float3 N, float3 V, float3 L, float roughness, float F0){
    float alpha = roughness*roughness;

    float3 H = normalize(V+L);

    float dotNL = clamp(dot(N,L),0.,1.);
    float dotNV = clamp(dot(N,V),0.,1.);
    float dotNH = clamp(dot(N,H),0.,1.);
    float dotLH = clamp(dot(L,H),0.,1.);

    float F, D;

    float alphaSqr = alpha*alpha;
    float pi = 3.14159;
    float denom = dotNH * dotNH *(alphaSqr - 1.0) + 1.0;
    D = alphaSqr/(pi * denom * denom);

    float dotLH5 = pow(1.0 - dotLH, 5.0);
    F = F0 + (1.0 - F0)*(dotLH5);

    float k = alpha * 0.5;

    return dotNL * D * F * G(dotNL,k)*G(dotNV,k);
}



kernel void compute(texture2d<float, access::write> output [[texture(0)]],  constant float &input [[buffer(0)]],
uint2 gid [[thread_position_in_grid]])
{
    //inputs
    uint width = output.get_width();
    uint height = output.get_height();
    float time = input;
    float2 res = float2(width, height);
    float2 uv = float2(gid.x,height - gid.y) / res;
    
    
    // quadratic, increase this if your gpu is gpu enough
    const int samples = 1;
    
    float3 c = float3(0);
    for(int y = 0; y < samples; ++y)
    for(int x = 0; x < samples; ++x){
        // anti-aliasing
        float2 p = -1.0 + 2.0 * (uv + (-0.5+(float2(x, y)))/res.xy);
        p.x *= res.x/res.y;
        
        // camera setup
        float3 cam = float3(0.1*sin(time*0.51),0.1*cos(time*0.59),time);
        float3 l = float3(0.6*cos(time*0.83),0.6*sin(time*0.79),cam.z+3.0+0.5*sin(0.7*time));
        float3 dir = normalize(float3(p, 2.0)+0.1*float3(sin(time*0.63),cos(time*0.71),0));
        
        // solve intersection and normal
        float3 pos = march(cam, dir, time);
        float3 mp = pos;
        float r = 3.14159*sin(mp.z*0.15)+time*0.25;
        mp.x = mp.x*cos(r) + mp.y*sin(r);
        mp.y = mp.x*sin(-r) + mp.y*cos(r);
        
        float3 np = pos+float3(0,0,-0.08*textureS(time, mp.xy*4.0).r);
        float3 n = normalize(mix(normal(np, time), pow(textureS(time, pos*2.0).xyz, float3(2)), 0.08));
        
        // shade
        float3 ld = normalize(l-pos);
        float3 alb = mix((float3(0.3,0.5,0.9)),
                       (float3(0.4,0.9,0.4)),
                       textureS(time, 0.04*mp).r)*1.25;

        float mat = smoothstep(0.1,0.8,pow(textureS(time, 0.14*mp).b, 3.0));
        alb = mix(alb, float3(0.9,0.78,0.42), mat);
        float dif = 0.5+0.5*dot(n, ld);
        float spe = ggx(n, -dir, ld, mix(0.3,0.5,mat), mix(0.7,1.0,mat));

        float att = 1.0+pow(distance(l, pos), 2.0);
        dif /= att;
        spe /= att;
        
        // subsurface scattering
        float3 h = normalize(mix(-normal(pos, time), dir, 0.5));
        // sv.zyz contains outgoing position, w contains accumulate distance (path "tightness)
        float4 sv = subsurface(pos+h*0.02, dir, time);
        // subsurface magic term
        float sss = max(0.0, 1.0-3.0*sv.w);
        // light visibility across the volume
        float ssha = max(0.0, dot(normal(sv.xyz, time), normalize(l-sv.xyz)));
        sss /= att;
        ssha /= att;
        
        // mix reflecting and refracting contributions
        dif = mix(dif, mix(sss, ssha, 0.2), 0.5);
       
        c += alb*dif+0.025*spe;
    }
    
    c = mix(float3(dot(c, float3(1,.1,.1))), c, 0.5);
    c = smoothstep(0.0, .75, c);
    c = pow(c, float3(1.0/2.2));
    float4 color  = float4(c, 1.);
    output.write(color, gid);
}
