//
//  shaders.metal
//  cube02
//
//  Created by LEE CHUL HYUN on 6/7/17.
//  Copyright © 2017 LEE CHUL HYUN. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct Vertex {
    float4 position [[position]];
    float2 texture;
};

struct VertexOut {
    float4 position [[position]];
    float2 texture;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
    float4x4 modelRotationMatrix;
    float speed;
};

struct InstanceUniforms {
    float4 position;
};

constant float PI = 3.14159;

vertex VertexOut vertex_main(device Vertex* vertices[[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint vid[[vertex_id]]) {
    
    VertexOut outVertex;
    
    float4 position = vertices[vid].position;
    outVertex.position = uniforms.modelViewProjectionMatrix * position;
    outVertex.texture = vertices[vid].texture;
    return outVertex;
}

fragment half4 textured_fragment(VertexOut vertexIn [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]],
                                 constant Uniforms &uniforms [[buffer(0)]]) {
    
    float x = 2 * (vertexIn.texture.x - 0.5);
    float y = 2 * (vertexIn.texture.y - 0.5);
    float dist = sqrt(x*x + y*y);
    if (dist > 1) {
        discard_fragment();
    }
    float angle = PI * uniforms.speed * dist / 4.0;
    float2x2 rotation = float2x2(cos(angle), sin(angle), -sin(angle), cos(angle));
    float2 textureCoord = rotation * float2(vertexIn.texture.x - 0.5, vertexIn.texture.y - 0.5) + float2(0.5, 0.5);
    float4 color = texture.sample(sampler2d, textureCoord);
    if (color.a == 0) {
        discard_fragment();
    }
    return half4(color.r, color.g, color.b, 1);
}

