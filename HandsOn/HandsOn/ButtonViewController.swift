//
//  ButtonViewController.swift
//  HandsOn
//
//  Created by Wataru Tsukagoshi on 2019/01/07.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController {

    @IBOutlet var labeltest :UILabel!
    @IBOutlet var buttonTest :UIButton!
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labeltest.text = "Swift Test"
        
        buttonTest.setTitle("Buttooon",for:UIControl.State.normal)
    }
    
    @IBAction func buttonTapped(_ sender : Any) {
        count += 1
        if(count%2 == 0){
            labeltest.text = "Swift Test"
        }
        else{
            labeltest?.text = "tapped !"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
