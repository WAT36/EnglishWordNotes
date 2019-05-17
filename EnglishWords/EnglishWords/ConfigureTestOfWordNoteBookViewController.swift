//
//  ConfigureTestOfWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/17.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class ConfigureTestOfWordNoteBookViewController: UIViewController {
    
    var wordnotebook: WordNoteBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnToConfigureWordNoteViewController",sender: nil)
        }else if(sender.tag == 1){
            //テスト実行(未実装)
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
