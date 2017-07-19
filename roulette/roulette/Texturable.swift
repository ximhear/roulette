//
//  Texturable.swift
//  roulette
//
//  Created by LEE CHUL HYUN on 7/20/17.
//  Copyright © 2017 gz. All rights reserved.
//

import MetalKit

protocol Texturable {
    var texture: MTLTexture? { get set }
}

extension Texturable {
    func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
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
                texture = try textureLoader.newTexture(withContentsOf: textureURL,
                                                       options: textureLoaderOptions)
            } catch {
                print("texture not created")
            }
        }
        return texture
    }
}
