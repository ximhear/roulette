//
//  RouletteLayerView.swift
//  roulette
//
//  Created by LEE CHUL HYUN on 7/23/17.
//  Copyright © 2017 gz. All rights reserved.
//

import UIKit

class RouletteLayerView: UIView {

    private var _diskImageName: String?
    var diskImageName: String? {
        get {
            return _diskImageName
        }
        
        set {
            _diskImageName = newValue
            if let imageName = newValue {
                self.layer.contents = UIImage(named: imageName)?.cgImage
            }
        }
    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        
        self.prepareViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
        self.prepareViews()
    }
    
    private func prepareViews() {
        self.layer.contentsGravity = "resizeAspect"
        self.backgroundColor = UIColor.clear
    }
    
    func startRotation(angle: Double) {
        GZLogFunc()
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        let toValue = angle
        rotate.duration = 10
        rotate.fromValue = 0
        //        rotate.isRemovedOnCompletion = false
        rotate.fillMode = kCAFillModeForwards
        rotate.toValue = toValue
        rotate.timingFunction = CAMediaTimingFunction(controlPoints: 0.0, 1.0, 1.0, 1)
        rotate.delegate = self
        
        self.layer.transform = CATransform3DMakeRotation(CGFloat(toValue), 0, 0, 1)
        self.layer.add(rotate, forKey: "")
    }

}

extension RouletteLayerView: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        GZLogFunc()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        GZLogFunc(flag)
    }
    
}
