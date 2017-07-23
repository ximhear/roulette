//
//  MetalVC.swift
//  roulette
//
//  Created by C.H Lee on 12/07/2017.
//  Copyright © 2017 gz. All rights reserved.
//

import UIKit
import Metal
import MetalKit

class MetalVC: UIViewController {

    @IBOutlet weak var metalView : GMetalView!
    var texture: MTLTexture?

    override func viewDidLoad() {
        super.viewDidLoad()

        makeTexture()
        addRect()
    }
    
    func addRect() {
        
        let vertices = [
            MBEVertex(position: vector_float4(-1, 1, 0, 1), texture:float2(0,0)),
            MBEVertex(position: vector_float4(-1, -1, 0, 1), texture:float2(0,1)),
            MBEVertex(position: vector_float4(1, -1, 0, 1), texture:float2(1,1)),
            MBEVertex(position: vector_float4(1, 1, 0, 1), texture:float2(1,0)),
            ]
        
        let rect = Rectangle(device: metalView.device!, imageName: "disk.png", vertices: vertices)
        
        metalView.addRenderable(rect)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.appProtocols.append(self.metalView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let index = AppDelegate.appProtocols.index(where: { (appProtocol) -> Bool in
            if self.metalView === appProtocol {
                return true
            }
            return false
        })
        if index != nil {
            AppDelegate.appProtocols.remove(at: index!)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func rotateClicked(_ sender: Any) {
        GZLogFunc()
        
//        metalView.startRotation(duration: 10.0, endingRotationZ: Double.pi * 20.5) { (tx) -> Double in
//            return -pow(1-tx, 2) + 1
//        }
        metalView.startRotation(duration: 10.0, endingRotationZ: Double.pi * 20.5,
                                timingFunction:  { (tx) -> Double in
                                    return pow(tx-1, 3) + 1
        },
                                speedFunction: { (tx) -> Double in
                                    return 3 * pow(tx-1, 2)
        })
//        metalView.startRotation(duration: 10.0, endingRotationZ: Double.pi * 21.25) { (tx) -> Double in
//
//            return self.bezierValue(cx0: 0, cy0: 0, cx1: 0, cy1: 0, cx2: 0, cy2: 1, cx3: 1, cy3: 1, tx: tx)
//        }
    }

    func bezierValue(cx0: Double, cy0: Double, cx1: Double, cy1: Double, cx2: Double, cy2: Double, cx3: Double, cy3: Double, tx: Double) -> Double {
        
        let t = pow(tx, 1.0/3.0)
        return cy0 * pow(1.0 - t , 3) + cy1 * pow(1.0 - t, 2) * tx + cy2 * (1.0 - t) * pow(t, 2) + cy3 * pow(t, 3)
    }

    func makeTexture() {
        self.texture = getTexture(device: metalView.device!, imageName: "disk.png")
    }
    
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
