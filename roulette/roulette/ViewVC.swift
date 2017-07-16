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
        
        UIView.animate(withDuration: 3, delay: 0, options: [UIViewAnimationOptions.curveLinear], animations: {
            GZLogFunc()
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
            self.imageView.transform = CGAffineTransform(rotationAngle: 0)
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
            self.imageView.transform = CGAffineTransform(rotationAngle: 0)
            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 1))
            self.imageView.transform = CGAffineTransform(rotationAngle: 0)
        }) { (completed) in
            GZLogFunc(completed)
        }
    }

}
