//
//  Renderer.swift
//  roulette
//
//  Created by LEE CHUL HYUN on 7/20/17.
//  Copyright © 2017 gz. All rights reserved.
//

import MetalKit

class Renderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    
    var samplerState: MTLSamplerState?

    var renderables : [Renderable] = []
    var depthTexture : MTLTexture?
    var depthStencilState : MTLDepthStencilState?

    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        buildSamplerState()
        makeDepthStencilState()
    }
    
    deinit {
        GZLogFunc()
    }
    
    private func buildSamplerState() {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: descriptor)
    }
    
    private func makeDepthStencilState() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
    
    func redraw(metalLayer: CAMetalLayer, uniforms: inout MBEUniforms) {
        
        let drawable = metalLayer.nextDrawable()
        let texture = drawable?.texture
        
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 0, alpha: 1)
        
        makeDepthTexture(metalLayer: metalLayer)
        passDescriptor.depthAttachment.texture = self.depthTexture
        passDescriptor.depthAttachment.clearDepth = 1.0
        passDescriptor.depthAttachment.loadAction = .clear
        passDescriptor.depthAttachment.storeAction = .dontCare
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor)
        commandEncoder?.setDepthStencilState(self.depthStencilState)
        commandEncoder?.setFragmentSamplerState(samplerState, index: 0)
        commandEncoder?.setFrontFacing(.counterClockwise)
        commandEncoder?.setCullMode(.back)
        
        commandEncoder?.setVertexBytes(&uniforms,
                                       length: MemoryLayout<MBEUniforms>.stride,
                                       index: 1)

        for renderable in self.renderables {
            
            renderable.redraw(commandEncoder: commandEncoder!)
        }
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable!)
        commandBuffer?.commit()
    }
    
    func makeDepthTexture(metalLayer: CAMetalLayer) {
        let drawableSize = metalLayer.drawableSize
        
        if let texture = depthTexture {
            if Int(drawableSize.width) == texture.width && Int(drawableSize.height) == texture.height {
                return
            }
        }
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(drawableSize.width), height: Int(drawableSize.height), mipmapped: false)
        desc.usage = .renderTarget
        depthTexture = device.makeTexture(descriptor: desc)
    }
    

    func addRenderable(_ renderable: Renderable) {
        renderables.append(renderable)
    }
}

