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
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        let toValue = Double.pi * 21 + .pi / 4.0
        rotate.duration = 10
        rotate.fromValue = 0
//        rotate.isRemovedOnCompletion = false
        rotate.fillMode = kCAFillModeForwards
        rotate.toValue = toValue
        rotate.timingFunction = CAMediaTimingFunction(controlPoints: 0.0, 1.0, 1.0, 1)
        rotate.delegate = self

        rouletteView.layer.transform = CATransform3DMakeRotation(CGFloat(toValue), 0, 0, 1)
        self.rouletteView.layer.add(rotate, forKey: "")
    }
}

extension LayerVC: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        GZLogFunc()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        GZLogFunc(flag)
    }

}
