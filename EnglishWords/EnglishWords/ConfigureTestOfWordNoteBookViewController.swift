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
    
    //検索条件のリスト
    var querylist: [String] = []

    
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
            performSegue(withIdentifier: "toTestFromConfigureTestOfWordNoteBookViewController", sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnToConfigureWordNoteViewController") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
        }else if(segue.identifier == "toTestFromConfigureTestOfWordNoteBookViewController"){
            let twnbVC: TestOfWordNoteBookViewController = (segue.destination as? TestOfWordNoteBookViewController)!
            twnbVC.wordnotebook = wordnotebook
        }
    }
}
