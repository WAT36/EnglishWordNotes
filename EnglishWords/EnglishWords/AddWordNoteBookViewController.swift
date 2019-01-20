//
//  AddWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by Wataru Tsukagoshi on 2019/01/19.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class AddWordNoteBookViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "単語帳追加画面"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
