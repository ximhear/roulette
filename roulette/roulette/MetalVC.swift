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

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
    
}
