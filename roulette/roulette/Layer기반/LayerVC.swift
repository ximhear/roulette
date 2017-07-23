//
//  LayerVC.swift
//  roulette
//
//  Created by C.H Lee on 16/07/2017.
//  Copyright © 2017 gz. All rights reserved.
//

import UIKit

class LayerVC: UIViewController {
    
    @IBOutlet weak var rouletteView: RouletteLayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rouletteView.diskImageName = "disk"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rotateClicked(_ sender: Any) {
        GZLogFunc()
        
        rouletteView.startRotation(angle: Double.pi * 21 + .pi / 4.0)
    }
}

