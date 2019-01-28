//
//  AddWordViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/28.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AddWordViewController: UIViewController {
    
    var wordnotebook: WordNoteBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        let button = sender as? UIButton
        if button!.tag == 0 {
            performSegue(withIdentifier: "ToConfigureWordNoteBookViewContoller",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToConfigureWordNoteBookViewContoller") {
            let cwnbVC2: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            // ConfigureWordNoteBookViewControllerのwordnotebookに設定している単語帳を設定
            cwnbVC2.wordnotebook = wordnotebook
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
