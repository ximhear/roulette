//
//  Rectangle.swift
//  cube02
//
//  Created by LEE CHUL HYUN on 6/19/17.
//  Copyright © 2017 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal
import simd
#if (arch(i386) || arch(x86_64)) && os(iOS)

    class Rectangle : Renderable, Texturable {
        
        init(device: MTLDevice, imageName: String, vertices: [MBEVertex], queue: MTLCommandQueue) {}
        func redraw() {}
        func texture() {}
    }

#else

    class Rectangle : Renderable, Texturable {
        
        var device : MTLDevice
        var vertexBuffer: MTLBuffer?
        var indexBuffer: MTLBuffer?
        var texture: MTLTexture?
        var vertices: [MBEVertex]
        
        // Renderable
        var pipelineState: MTLRenderPipelineState!
        var fragmentFunctionName: String = "textured_fragment"
        var vertexFunctionName: String = "vertex_main"
        var vertexDescriptor: MTLVertexDescriptor {
            let vertexDescriptor = MTLVertexDescriptor()
            
            vertexDescriptor.attributes[0].format = .float4
            vertexDescriptor.attributes[0].offset = 0
            vertexDescriptor.attributes[0].bufferIndex = 0
            
            vertexDescriptor.attributes[1].format = .float2
            vertexDescriptor.attributes[1].offset = MemoryLayout<float4>.stride
            vertexDescriptor.attributes[1].bufferIndex = 0
            
            vertexDescriptor.layouts[0].stride = MemoryLayout<MBEVertex>.stride
            
            return vertexDescriptor
        }

        init(device: MTLDevice, imageName: String, vertices: [MBEVertex], queue: MTLCommandQueue) {
            self.device = device
            self.vertices = vertices
            self.texture = setTexture(device: device, imageName: imageName, queue: queue)
            pipelineState = buildPipelineState(device: device)
            makeBuffers()
        }
        
        func redraw(commandEncoder: MTLRenderCommandEncoder) -> Void {
            
            commandEncoder.setRenderPipelineState(pipelineState)
            commandEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
            commandEncoder.setFragmentTexture(self.texture, index: 0)

            commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: self.indexBuffer!.length / MemoryLayout<UInt16>.size, indexType: .uint16, indexBuffer: self.indexBuffer!, indexBufferOffset: 0)
            
        }
        
        func makeBuffers() {
            
            let indices : [UInt16] = [
                0, 1, 2, 2, 3, 0
            ]
            
            self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<MBEVertex>.stride, options: [])
            self.indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
        }
    }

#endif

