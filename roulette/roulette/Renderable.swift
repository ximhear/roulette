//
//  Renderable.swift
//  cube02
//
//  Created by LEE CHUL HYUN on 6/19/17.
//  Copyright © 2017 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

protocol Renderable {
    var texture: MTLTexture? {get set}
    func redraw(commandEncoder: MTLRenderCommandEncoder) -> Void
}
