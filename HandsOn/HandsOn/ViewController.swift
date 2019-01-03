//
//  ViewController.swift
//  HandsOn
//
//  Created by Wataru Tsukagoshi on 2019/01/04.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        label.text = "Hello World!"
    }


}

