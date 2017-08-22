//
//  GTextureLoader.swift
//  roulette
//
//  Created by C.H Lee on 22/08/2017.
//  Copyright © 2017 gz. All rights reserved.
//

import UIKit
import Metal
import CoreGraphics

class GTextureLoader {

    static var shared: GTextureLoader = GTextureLoader()
    
    func dataForImage(image: UIImage) -> UnsafeMutablePointer<UInt8> {
        let imageRef = image.cgImage!
        
        // Create a suitable bitmap context for extracting the bits of the image
        let width = imageRef.width
        let height = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        let context = CGContext.init(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)!
        
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        
        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(imageRef, in: imageRect)
        
        return rawData;
    }

    func generateMipmaps(texture: MTLTexture, onQueue queue: MTLCommandQueue) -> Void {
        let commandBuffer = queue.makeCommandBuffer()
        let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
        blitEncoder?.generateMipmaps(for: texture)
        blitEncoder?.endEncoding()
        commandBuffer?.commit()
    
        // block
        commandBuffer?.waitUntilCompleted()
    }


    func texture2D(imageNamed name: String, mipmapped: Bool, queue: MTLCommandQueue) -> MTLTexture? {

        guard let image = UIImage(named: name) else {
            return nil
        }

        let imageSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
        let bytesPerPixel: UInt = 4
        let bytesPerRow: UInt  = bytesPerPixel * UInt(imageSize.width)
        let imageData = dataForImage(image: image)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(imageSize.width), height: Int(imageSize.height), mipmapped: mipmapped)
        guard let texture = queue.device.makeTexture(descriptor: textureDescriptor) else {
            free(imageData)
            return nil
        }
        
        texture.label = name
        
        let region = MTLRegionMake2D(0, 0, Int(imageSize.width), Int(imageSize.height))
        texture.replace(region: region, mipmapLevel: 0, withBytes: imageData, bytesPerRow: Int(bytesPerRow))
        
        free(imageData)
        
        if mipmapped == true {
            generateMipmaps(texture: texture, onQueue: queue)
        }
        
        return texture

    }
    
    
}
