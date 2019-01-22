//
//  AddWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by Wataru Tsukagoshi on 2019/01/19.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

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
    
    @IBAction func buttonTapped(sender : AnyObject) {
        performSegue(withIdentifier: "AddBookandToViewController",sender: nil)
        
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddBookandToViewController") {
            //ここでRealm使って書き込み行わせてから戻る
            let realm = try! Realm()
            try! realm.write {
                let wordnotebook = WordNoteBook(value:
                    ["wordNoteBookId": 1,
                     "wordNoteBookName": textField.text,
                     "createdDate": Date()])
                realm.add(wordnotebook)
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
