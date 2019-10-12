//
//  AddWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/19.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AddWordNoteBookViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    let aa = AlertAction()
    
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
    
    @IBAction func buttonTapped(sender : UIButton) {
        if (sender.tag == 0){
            if textField.text!.isEmpty {
                aa.showErrorAlert(vc:self,m: "単語帳名が入力されていません")
            }else if(self.checkRegisteredWordNoteBook(wordnotebookname: (textField.text?.trimmingCharacters(in: .whitespaces))!)){
                aa.showErrorAlert(vc:self,m:"既に同じ名前の単語帳が登録されています")
            }else{
                performSegue(withIdentifier: "AddBookandToViewController",sender: nil)
            }
        }else if(sender.tag == 1){
            performSegue(withIdentifier: "ReturnToViewController",sender: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddBookandToViewController") {
            //Realm
            //現在ある最大の単語帳IDを取得
            let realm = try! Realm()
            let results = realm.objects(WordNoteBook.self)
            var maxId: Int
            if results.count > 0 {
                maxId = results.value(forKeyPath: "@max.wordNoteBookId")! as! Int
            }else{
                maxId = -1
            }
            
            try! realm.write {
                //単語帳追加(単語帳IDは現最大ID + 1)
                realm.add([WordNoteBook(value: ["wordNoteBookId": (maxId + 1),
                                                "wordNoteBookName": textField.text!,
                                                "createdDate": Date()])])
            }
            
        }
    }
    
    //既に同じ単語帳が登録されているかチェック
    func checkRegisteredWordNoteBook(wordnotebookname: String) -> Bool{
        //Realm
        let realm = try! Realm()
        let results = realm.objects(WordNoteBook.self).filter("wordNoteBookName = %@",wordnotebookname)
        if results.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
