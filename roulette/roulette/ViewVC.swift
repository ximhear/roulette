//
//  ViewVC.swift
//  roulette
//
//  Created by LEE CHUL HYUN on 7/16/17.
//  Copyright © 2017 gz. All rights reserved.
//

import UIKit

class ViewVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        GZLogFunc()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = UIImage(named: "disk")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func rotateClicked(_ sender: Any) {
        GZLogFunc()
        
        UIView.animate(withDuration: 3, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            GZLogFunc()
            for _ in 0..<10 {
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
                self.imageView.transform = CGAffineTransform(rotationAngle: 0)
            }
        }) { (completed) in
            GZLogFunc(completed)
        }
//        UIView.animate(withDuration: 7.5, delay: 2.0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
//            GZLogFunc()
//            for _ in 0..<1 {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
//                self.imageView.transform = CGAffineTransform(rotationAngle: 0)
//            }
//            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/1))
//        }) { (completed) in
//            GZLogFunc(completed)
//        }

//        UIView.animateKeyframes(withDuration: 10, delay: 0, options: [.calculationModePaced], animations: {
//            GZLogFunc()
//
//            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 1.0, relativeDuration: 0.5, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 1.5, relativeDuration: 1, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 2.5, relativeDuration: 1, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 3.5, relativeDuration: 2, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 5.5, relativeDuration: 2, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2))
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
//            })
//            UIView.addKeyframe(withRelativeStartTime: 7.5, relativeDuration: 2.5, animations: {
//                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
//            })
//
//        }) { (completed) in
//            GZLogFunc(completed)
//        }
    }

}
