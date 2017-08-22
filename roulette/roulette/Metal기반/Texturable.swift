//
//  Texturable.swift
//  roulette
//
//  Created by LEE CHUL HYUN on 7/20/17.
//  Copyright © 2017 gz. All rights reserved.
//

import MetalKit

#if (arch(i386) || arch(x86_64)) && os(iOS)
    
    protocol Texturable {
        func texture()
    }
    
#else
    
    protocol Texturable {
        var texture: MTLTexture? { get set }
    }
    
    
    extension Texturable {
        func setTexture(device: MTLDevice, imageName: String, queue: MTLCommandQueue) -> MTLTexture? {

            if #available(iOS 9.0, *) {
                
                let textureLoader = MTKTextureLoader(device: device)
                var texture: MTLTexture? = nil
                let textureLoaderOptions: [MTKTextureLoader.Option : Any]
                if #available(iOS 10.0, *) {
                    let origin = MTKTextureLoader.Origin.topLeft
                    textureLoaderOptions = [MTKTextureLoader.Option.origin : origin,
                                            MTKTextureLoader.Option.generateMipmaps: true]
                } else {
                    textureLoaderOptions = [:]
                }
                
                if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil) {
                    do {
                        texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
                    } catch {
                        print("texture not created")
                    }
                }
                return texture
            }
            else {
                let texture = GTextureLoader.shared.texture2D(imageNamed: imageName, mipmapped: true, queue: queue)
                return texture
            }
        }
    }
    
#endif
