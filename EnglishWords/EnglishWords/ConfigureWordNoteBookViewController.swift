//
//  ConfigureWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/23.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class ConfigureWordNoteBookViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    
    var wordnotebook:WordNoteBook = WordNoteBook(value: ["wordNoteBookId": 0,
                                                          "wordNoteBookName": "ダミー",
                                                          "createdDate": Date()])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = wordnotebook.wordNoteBookName
    }
    
    @IBAction func buttonTapped(sender : AnyObject) {
        performSegue(withIdentifier: "DeleteBookandToViewController",sender: nil)
        
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DeleteBookandToViewController") {
            //Realm
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(wordnotebook)
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
