//
//  ConfigureWordViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/02/03.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ConfigureWordViewController: UIViewController{
    
    @IBOutlet var wordnamelabel: UILabel!
    @IBOutlet var table:UITableView!
    
    var wordnotebook: WordNoteBook?
    var wordnote: WordNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordnamelabel.text = wordnote?.worddata?.word?.wordName
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender : AnyObject) {
        performSegue(withIdentifier: "returnConfigureWordViewController",sender: nil)
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnConfigureWordViewController") {
            let configureWordNoteVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            configureWordNoteVC.wordnotebook = wordnotebook
        }
    }
    
}
