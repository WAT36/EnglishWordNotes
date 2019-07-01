//
//  OptionConfigureWordNoteViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/07/01.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class OptionConfigureWordNoteViewController: UIViewController{
    
    @IBOutlet var viewName: UILabel!

    var wordnotebook: WordNoteBook?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面名ラベル設定、２行
        viewName.text = "単語帳設定\nオプション"
        viewName.numberOfLines = 2
        
        
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnToConfigureWordNoteViewController",sender: nil)
        }else if(sender.tag == 1){
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnToConfigureWordNoteViewController") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
        }
    }
    
}
