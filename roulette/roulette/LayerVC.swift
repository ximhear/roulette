//
//  LayerVC.swift
//  roulette
//
//  Created by C.H Lee on 16/07/2017.
//  Copyright © 2017 gz. All rights reserved.
//

import UIKit

class LayerVC: UIViewController {
    
    @IBOutlet weak var rouletteView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rouletteView.layer.contents = UIImage(named: "disk")?.cgImage
        rouletteView.layer.contentsGravity = "resizeAspect"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rotateClicked(_ sender: Any) {
        GZLogFunc()
        
//        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
//        let toValue = Double.pi * 21
//        rotate.duration = 10
//        rotate.fromValue = 0
////        rotate.isRemovedOnCompletion = false
//        rotate.fillMode = kCAFillModeForwards
//        rotate.toValue = toValue
//
//        rouletteView.layer.transform = CATransform3DMakeRotation(CGFloat(toValue), 0, 0, 1)
//        self.rouletteView.layer.add(rotate, forKey: "")
        
        let rotate = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        let duration: Int = 10
        let fps : Int = 60
        rotate.duration = CFTimeInterval(duration)
        var keyTimes = [NSNumber]()
        var values = [Double]()
        let b: Double = Double.pi * 21 + Double.pi / 4
        for x in 0...(duration * fps) {
            let xx = Double(x) / Double(fps)
            keyTimes.append(NSNumber(value: xx / Double(duration)))
            values.append(-b / Double(duration*duration) * (xx - Double(duration) ) * (xx - Double(duration) ) + b)
        }
        rotate.keyTimes = keyTimes
        rotate.values = values

        GZLogFunc(rotate.keyTimes)
        GZLogFunc(rotate.values)
        rotate.fillMode = kCAFillModeForwards
        rouletteView.layer.transform = CATransform3DMakeRotation(CGFloat(b), 0, 0, 1)
        self.rouletteView.layer.add(rotate, forKey: nil)
        
    }
}
