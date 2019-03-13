//
//  AddPartsofSpeechViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/27.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AddPartsofSpeechViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "新しく追加する品詞名を記入して下さい"
        
        // textField の情報を受け取るための delegate を設定
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func buttonTapped(sender : UIButton) {        
        if (sender.tag == 0){
            if textField.text!.isEmpty {
                self.showAlert(m: "品詞名が入力されていません")
            }else if(self.checkRegisteredPartOfSpeech(partsofspeechname: (textField.text?.trimmingCharacters(in: .whitespaces))!)){
                self.showAlert(m: "既に同じ品詞名が登録されています")
            }else{
                performSegue(withIdentifier: "AddPartsofSpeechandToViewController",sender: nil)
            }
        }else if(sender.tag == 1){
            performSegue(withIdentifier: "ReturnToViewController",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AddPartsofSpeechandToViewController") {
            //Realm
            let realm = try! Realm()
            let results = realm.objects(PartsofSpeech.self)
            var maxId: Int
            if results.count == 0 {
                maxId = results.count
            }else{
                maxId = results.value(forKeyPath: "@max.partsOfSpeechId")! as! Int
            }
            try! realm.write {
                realm.add([PartsofSpeech(value: ["partsOfSpeechId": (maxId + 1),
                                                "partsOfSpeechName": textField.text!,
                                                "createdDate": Date()])])
            }
            
        }
    }
    
    //既に同じ品詞が登録されているかチェック
    func checkRegisteredPartOfSpeech(partsofspeechname: String) -> Bool{
        //Realm
        let realm = try! Realm()
        let results = realm.objects(PartsofSpeech.self).filter("partsOfSpeechName = %@",partsofspeechname)
        if results.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    func showAlert(m: String) {
        
        // アラートを作成
        let alert = UIAlertController(
            title: "エラー",
            message: m,
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

