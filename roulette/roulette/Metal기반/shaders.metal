//
//  shaders.metal
//  cube02
//
//  Created by LEE CHUL HYUN on 6/7/17.
//  Copyright © 2017 LEE CHUL HYUN. All rights reserved.
//

#include <metal_stdlib>
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
};

struct InstanceUniforms {
    float4 position;
};

vertex VertexOut vertex_main(device Vertex* vertices[[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint vid[[vertex_id]]) {
    
    VertexOut outVertex;
    
    float4 position = vertices[vid].position;
    outVertex.position = uniforms.modelViewProjectionMatrix * position;
    outVertex.texture = vertices[vid].texture;
    return outVertex;
}

fragment half4 textured_fragment(Vertex vertexIn [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]] ) {
    float4 color = texture.sample(sampler2d, vertexIn.texture);
    if (color.a == 0) {
        discard_fragment();
    }
    return half4(color.r, color.g, color.b, 1);
}

