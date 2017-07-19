//
//  GMetalView.swift
//  roulette
//
//  Created by C.H Lee on 12/07/2017.
//  Copyright © 2017 gz. All rights reserved.
//

import UIKit
import Metal
import QuartzCore
import simd
import MetalKit

struct MBEVertex {
    var position : vector_float4
    var texture : float2 = float2(0, 0)
}

struct MBEUniforms {
    var modelViewProjectionMatrix : matrix_float4x4
    var modelRotationMatrix : matrix_float4x4
}



#if (arch(i386) || arch(x86_64)) && os(iOS)
    
    class GMetalView: UIView {
    }
    
    extension GMetalView : AppProtocol {
        
        func applicationWillResignActive() {
        }
        
        func applicationDidBecomeActive() {
        }
    }
    
#else
    
    class GMetalView: UIView {
        
        /*
         // Only override draw() if you perform custom drawing.
         // An empty implementation adversely affects performance during animation.
         override func draw(_ rect: CGRect) {
         // Drawing code
         }
         */
        
        var device : MTLDevice?
        //    var vertexBuffer: MTLBuffer?
        //    var indexBuffer: MTLBuffer?
        var pipeline : MTLRenderPipelineState?
        var depthStencilState : MTLDepthStencilState?
        var depthTexture : MTLTexture?
        var commandQueue : MTLCommandQueue?
        var displayLink : CADisplayLink?
        var elapsedTime : Double = 0
        var rotationZ : Double = 0
        var texture: MTLTexture?
        var samplerState: MTLSamplerState?
        
        var renderables : [Renderable] = []
        
        var timingFunction: ((_ tx: Double) -> Double)?
        var beginingTime: TimeInterval = 0
        var endingTime: TimeInterval = 0
        var rotating = false
        var beginingRotationZ: Double = 0
        var endingRotationZ: Double = 0
        
        override class var layerClass: Swift.AnyClass {
            return CAMetalLayer.self
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            super.init(coder: aDecoder)
            
            self.makeDevice()
            buildSamplerState()
            makeTexture()
            //        makeBuffers()
            makePipeline()
            addRect()
        }
        
        deinit {
            GZLogFunc()
            displayLink?.invalidate()
        }
        
        var metalLayer : CAMetalLayer? {
            return self.layer as? CAMetalLayer
        }
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            if self.superview != nil {
                if displayLink == nil {
                    displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
                    displayLink?.add(to: RunLoop.main, forMode: .commonModes)
                }
            }
            else {
                displayLink?.invalidate()
                displayLink = nil
            }
        }
        
        @objc func displayLinkDidFire() {

            if self.rotating == true {
                let fps : Double = 1.0 / 60.0
                elapsedTime += fps
                
                if self.beginingTime + elapsedTime >= self.endingTime {
                    self.rotationZ = self.endingRotationZ
                    self.rotating = false
                    GZLogFunc("Rotation ended")
                }
                else {
                    var result: Double = 0
                    if let timingFunction = self.timingFunction {
                        result = beginingRotationZ + timingFunction(elapsedTime/(self.endingTime - self.beginingTime)) * (self.endingRotationZ - beginingRotationZ)
                    }
                    else {
                        result = beginingRotationZ + (self.endingRotationZ - beginingRotationZ) * elapsedTime / (self.endingTime - self.beginingTime)
                    }
                    self.rotationZ = result
                }
            }
            redraw()
        }
        
        private func buildSamplerState() {
            let descriptor = MTLSamplerDescriptor()
            descriptor.minFilter = .linear
            descriptor.magFilter = .linear
            samplerState = self.device!.makeSamplerState(descriptor: descriptor)
        }
        
        func redraw() {
            
            let drawable = self.metalLayer?.nextDrawable()
            let texture = drawable?.texture
            
            let scaleFactor: Float = 1.0 //sin(2.5 * self.elapsedTime) * 1.75 + 2.0
            let zAxis = vector_float3(0, 0, 1)
            let zRot = matrix_float4x4_rotation(axis: zAxis, angle: Float(rotationZ))
            let scale = matrix_float4x4_uniform_scale(scale: scaleFactor)
            let modelMatrix = matrix_multiply(zRot, scale)
            
            let cameraTranslation = vector_float3(0, 0, 0.0)
            let viewMatrix = matrix_float4x4_translation(t: cameraTranslation)
            
            let drawableSize = self.metalLayer!.drawableSize
            let aspect: Float = Float(drawableSize.width / drawableSize.height)
            var projectionMatrix: matrix_float4x4?
            if drawableSize.width > drawableSize.height {
                projectionMatrix = matrix_float4x4_ortho(left: -1 * aspect, right: 1 * aspect, bottom: -1, top: 1, near: 1, far: -1)
            }
            else {
                projectionMatrix = matrix_float4x4_ortho(left: -1, right: 1, bottom: -1 / aspect, top: 1 / aspect, near: 1, far: -1)
            }
            
            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = texture
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].storeAction = .store
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 0, alpha: 1)
            
            makeDepthTexture()
            passDescriptor.depthAttachment.texture = self.depthTexture
            passDescriptor.depthAttachment.clearDepth = 1.0
            passDescriptor.depthAttachment.loadAction = .clear
            passDescriptor.depthAttachment.storeAction = .dontCare
            
            let commandBuffer = commandQueue?.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor)
            commandEncoder?.setRenderPipelineState(self.pipeline!)
            commandEncoder?.setDepthStencilState(self.depthStencilState)
            commandEncoder?.setFragmentSamplerState(samplerState, index: 0)
            commandEncoder?.setFragmentTexture(self.texture, index: 0)
            commandEncoder?.setFrontFacing(.counterClockwise)
            commandEncoder?.setCullMode(.back)
            
            var uniforms = MBEUniforms(modelViewProjectionMatrix: matrix_multiply(projectionMatrix!, matrix_multiply(viewMatrix, modelMatrix)), modelRotationMatrix: zRot)
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
        
        func makeDevice() {
            self.device = MTLCreateSystemDefaultDevice()!
            self.metalLayer?.device = self.device
            self.metalLayer?.pixelFormat = .bgra8Unorm
        }
        
        func addRect() {
            
            var vertices = [
                MBEVertex(position: vector_float4(-1, 1, 0, 1), texture:float2(0,0)),
                MBEVertex(position: vector_float4(-1, -1, 0, 1), texture:float2(0,1)),
                MBEVertex(position: vector_float4(1, -1, 0, 1), texture:float2(1,1)),
                MBEVertex(position: vector_float4(1, 1, 0, 1), texture:float2(1,0)),
                ]
            
            let rect = Rectangle(device: self.device!, texture: self.texture!, vertices: vertices)
            self.renderables.append(rect)
        }
        
        func makePipeline() {
            let library = device?.makeDefaultLibrary()
            let vertexFunc = library?.makeFunction(name: "vertex_main")
            //        let fragmentFunc = library?.makeFunction(name: "fragment_main")
            let fragmentFunc = library?.makeFunction(name: "textured_fragment")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunc
            pipelineDescriptor.fragmentFunction = fragmentFunc
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            let depthStencilDescriptor = MTLDepthStencilDescriptor()
            depthStencilDescriptor.depthCompareFunction = .less
            depthStencilDescriptor.isDepthWriteEnabled = true
            self.depthStencilState = self.device?.makeDepthStencilState(descriptor: depthStencilDescriptor)
            
            self.pipeline = try? self.device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
            
            self.commandQueue = self.device?.makeCommandQueue()
        }
        
        func makeDepthTexture() {
            let drawableSize = self.metalLayer!.drawableSize
            
            if let texture = self.depthTexture {
                if Int(drawableSize.width) == texture.width && Int(drawableSize.height) == texture.height {
                    return
                }
            }
            let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float, width: Int(drawableSize.width), height: Int(drawableSize.height), mipmapped: false)
            desc.usage = .renderTarget
            depthTexture = self.device?.makeTexture(descriptor: desc)
        }
        
        func makeTexture() {
            self.texture = getTexture(device: self.device!, imageName: "disk.png")
        }
        
        func getCubeTextureImmediately(device: MTLDevice, images:[String]) -> MTLTexture? {
            
            let image = UIImage(named: images[0])!
            let cubeSize = image.size.width * image.scale
            let bytePerPixel = 4
            let bytesPerRow = bytePerPixel * Int(cubeSize)
            let bytePerImage = bytesPerRow * Int(cubeSize)
            var texture : MTLTexture?
            
            let region = MTLRegionMake2D(0, 0, Int(cubeSize), Int(cubeSize))
            let textureDescriptor = MTLTextureDescriptor.textureCubeDescriptor(pixelFormat: .rgba8Unorm, size: Int(cubeSize), mipmapped: false)
            texture = device.makeTexture(descriptor: textureDescriptor)
            
            for slice in 0..<6 {
                let image = UIImage(named: images[slice])
                let data = dataForImage(image: image!)
                
                texture?.replace(region: region, mipmapLevel: 0, slice: slice, withBytes: data, bytesPerRow: bytesPerRow, bytesPerImage: bytePerImage)
            }
            return texture
        }
        
        func dataForImage(image: UIImage) -> UnsafeMutablePointer<UInt8> {
            let imageRef = image.cgImage
            let width = Int(image.size.width)
            let height = Int(image.size.height)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
            let bytePerPixel = 4
            let bytesPerRow = bytePerPixel * Int(width)
            let bitsPerComponent = 8
            let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue + CGImageAlphaInfo.premultipliedLast.rawValue
            let context = CGContext.init(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            context?.draw(imageRef!, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            return rawData
        }
        
        func matrix_float4x4_translation(t:vector_float3) -> matrix_float4x4 {
            let X = vector_float4( 1, 0, 0, 0 )
            let Y = vector_float4(0, 1, 0, 0 )
            let Z = vector_float4( 0, 0, 1, 0 )
            let W = vector_float4(t.x, t.y, t.z, 1 )
            
            let mat = matrix_float4x4(columns:( X, Y, Z, W ))
            return mat
        }
        
        func matrix_float4x4_uniform_scale(scale:Float) -> matrix_float4x4 {
            let X = vector_float4( scale, 0, 0, 0 )
            let Y = vector_float4( 0, scale, 0, 0 )
            let Z = vector_float4( 0, 0, scale, 0 )
            let W = vector_float4( 0, 0, 0, 1 )
            
            let mat = matrix_float4x4(columns:( X, Y, Z, W ))
            return mat
        }
        
        func matrix_float4x4_rotation(axis:vector_float3, angle:Float) -> matrix_float4x4 {
            let c = cos(angle)
            let s = sin(angle)
            
            var X = vector_float4()
            X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c;
            X.y = axis.x * axis.y * (1 - c) - axis.z * s;
            X.z = axis.x * axis.z * (1 - c) + axis.y * s;
            X.w = 0.0;
            
            var Y = vector_float4()
            Y.x = axis.x * axis.y * (1 - c) + axis.z * s;
            Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c;
            Y.z = axis.y * axis.z * (1 - c) - axis.x * s;
            Y.w = 0.0;
            
            var Z = vector_float4()
            Z.x = axis.x * axis.z * (1 - c) - axis.y * s;
            Z.y = axis.y * axis.z * (1 - c) + axis.x * s;
            Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c;
            Z.w = 0.0;
            
            var W = vector_float4()
            W.x = 0.0;
            W.y = 0.0;
            W.z = 0.0;
            W.w = 1.0;
            
            let mat = matrix_float4x4(columns:( X, Y, Z, W ))
            return mat
        }
        
        func matrix_float4x4_perspective(aspect:Float, fovy:Float, near:Float, far:Float) -> matrix_float4x4 {
            let yScale = 1 / tan(fovy * 0.5);
            let xScale = yScale / aspect;
            let zRange = far - near;
            let zScale = -(far + near) / zRange;
            let wzScale = -2 * far * near / zRange;
            
            let P = vector_float4( xScale, 0, 0, 0 )
            let Q = vector_float4( 0, yScale, 0, 0 )
            let R = vector_float4( 0, 0, zScale, -1 )
            let S = vector_float4( 0, 0, wzScale, 0 )
            
            let mat = matrix_float4x4(columns:( P, Q, R, S ))
            return mat
        }
        
        func matrix_float4x4_ortho(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> matrix_float4x4 {
            
            let P = vector_float4( 2 / (right - left), 0, 0, 0 )
            let Q = vector_float4( 0, 2 / (top - bottom), 0, 0 )
            let R = vector_float4( 0, 0, -2 / (far - near), 0 )
            let S = vector_float4( -(right + left) / (right - left), -(top + bottom) / (top - bottom), -(far + near) / (far - near), 1 )
            
            let mat = matrix_float4x4(columns:( P, Q, R, S ))
            return mat
        }
        
        override var bounds: CGRect {
            get {
                return super.bounds
            }
            set {
                super.bounds = newValue
                var scale = UIScreen.main.scale
                if let w = self.window {
                    scale = w.screen.scale
                }
                var drawableSize = self.bounds.size
                drawableSize.width *= scale
                drawableSize.height *= scale
                
                self.metalLayer?.drawableSize = drawableSize
                
                self.makeDepthTexture()
            }
        }
    }
    
    extension GMetalView {
        
        func getTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
            let textureLoader = MTKTextureLoader(device: device)
            var texture: MTLTexture? = nil
            let textureLoaderOptions: [MTKTextureLoader.Option : Any]
            if #available(iOS 10.0, *) {
                let origin = MTKTextureLoader.Origin.topLeft
                textureLoaderOptions = [MTKTextureLoader.Option.origin: origin,
                                        MTKTextureLoader.Option.generateMipmaps:true]
            } else {
                textureLoaderOptions = [:]
            }
            
            if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil) {
                do {
                    texture = try textureLoader.newTexture(withContentsOf: textureURL,
                                                           options: textureLoaderOptions)
                } catch {
                    GZLogFunc("texture not created")
                }
            }
            return texture
        }
        
    }
    
    extension GMetalView : AppProtocol {
        
        func applicationWillResignActive() {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        func applicationDidBecomeActive() {
            
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
                displayLink?.add(to: RunLoop.main, forMode: .commonModes)
            }
        }
    }
    
    extension GMetalView {
        func startRotation(duration: TimeInterval, endingRotationZ: Double, timingFunction: ((_ tx: Double) -> Double)?) {
            GZLogFunc("Rotation started")

            self.timingFunction = timingFunction
            if duration > 0 {
                self.beginingTime = Date().timeIntervalSince1970
                self.elapsedTime = 0
                self.endingTime = self.beginingTime + duration
                self.rotating = true
                self.rotationZ = self.rotationZ.truncatingRemainder(dividingBy: Double.pi * 2.0)
                self.beginingRotationZ = self.rotationZ
                self.endingRotationZ = endingRotationZ
            }
            else {
                self.rotating = false
            }
        }
    }
    
#endif
