//
//  ViewController.swift
//  testMetal
//
//  Created by 有本淳吾 on 2018/06/28.
//  Copyright © 2018 有本淳吾. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let mtlView = MetalView()
        mtlView.setup()
        mtlView.setPoints()
        self.view = mtlView
        
    }

}

