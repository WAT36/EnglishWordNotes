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
    
    @IBAction func buttonTapped(sender : AnyObject) {
        performSegue(withIdentifier: "AddPartsofSpeechandToViewController",sender: nil)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

