//
//  AddWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by Wataru Tsukagoshi on 2019/01/19.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class AddWordNoteBookViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "新しく追加する単語帳名を記入して下さい"
        
        // textField の情報を受け取るための delegate を設定
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
