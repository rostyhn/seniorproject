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

float2 onRep(float2 p, float interval) {
    return fmod(p, interval) - interval * 0.75;
}

float barDist(float2 p, float interval, float width) {
    return length(max(abs(onRep(p, interval)) - width, 0.0));
}

float sceneDist(float3 p) {
    float bar_x = barDist(p.yz, 0.5, 0.01);
    float bar_y = barDist(p.xz, 0.5, 0.01);
    float bar_z = barDist(p.xy, 0.5, 0.01);

    return min(min(bar_x, bar_y), bar_z);
}
kernel void compute(texture2d<float, access::write> output [[texture(0)]],  constant float &input [[buffer(0)]],
uint2 gid [[thread_position_in_grid]])
{
    //inputs
    uint width = output.get_width();
    uint height = output.get_height();
    float time = input;
    float2 res = float2(width, height);
    float2 p = float2(gid.x,height - gid.y) / res;
    //p -= 0.5;
    p.x *= res.x/res.y;

    
    float3 cameraPos = float3(0, 7.5,  time);
    float screenZ = 2.5;
    float3 rayDirection = normalize(float3(p, screenZ));

    float depth = 0.0;
    float3 col = float3(0.0);

    for (int i = 0; i < 99; i++) {
        float3 rayPos = cameraPos + rayDirection * depth;
        float dist = sceneDist(rayPos);

        if (dist < 0.0001) {
            col = float3(.0, 0.4, 0.7) * (1.0 - float(i) / 100.0);
            break;
        }

        depth += dist;
    }

    float4 color = float4(col, 1.0);
    
    output.write(color, gid);
}


/*kernel void compute(texture2d<float, access::write> output [[texture(0)]],  constant float &input [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]])
{
    uint width = output.get_width();
    uint height = output.get_height();
    float time = input;
    float2 r = float2(width, height);
    float2 gidToFloat = (float(gid.x), float(gid.y));
    float2 uv = float2(gid.x,height - gid.y) / r;
    uv -= 0.5;
    uv.x *= r.x/r.y;
    
    float2 a = r / min(r.x,r.y);
    float2 p = (gidToFloat.xy/r.xy)*a;
    float c=p.y+sin(p.x*10.+(time/5.0+994.1)*cos(p.y*100.)*10.)*.5+.5;
    if(p.y<a.y*.05||p.y>a.y*.95||p.x<a.x*.05||p.x>a.x*.95)c=.0;
    float4 color = float4(float3(c*.1,c*.5,c),1.);
    
    output.write(color, gid);
}*/
