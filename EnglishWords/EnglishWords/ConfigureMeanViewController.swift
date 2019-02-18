//
//  ConfigureMeanViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/02/05.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ConfigureMeanViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    var mean: WordData?
    var partsofspeechlist: [PartsofSpeech] = []
    var selectedpartofspeech: PartsofSpeech?
    var newMeanFlag: Bool?
    
    @IBOutlet var partofspeeches: UIPickerView!
    @IBOutlet var textField: UITextField!
    
    let notSelectedPartOfSpeech: String = "---品詞を選択してください---"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate設定
        partofspeeches.delegate = self
        partofspeeches.dataSource = self
        
        //データベース内に保存してあるPartsofSpeechを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(PartsofSpeech.self)
        partsofspeechlist = Array(results)
        
        //品詞PickerViewに初期値用データを挿入
        partsofspeechlist.insert(PartsofSpeech(value: ["partsOfSpeechId": -1,
                                                       "partsOfSpeechName": notSelectedPartOfSpeech,
                                                       "createdDate": Date()]), at: 0)
        selectedpartofspeech = partsofspeechlist[0]
        
        //テキストフィールドの初期値に登録されてある意味
        if !newMeanFlag! {
            textField.text = mean?.mean
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return partsofspeechlist.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return partsofspeechlist[row].partsOfSpeechName
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        selectedpartofspeech = partsofspeechlist[row]
    }
    
    @IBAction func buttonTapped(sender : AnyObject) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnToConfigureWordViewController",sender: nil)
        }else if(sender.tag == 1){
            if(mean?.word == nil){
                showAlert(errormessage: "エラー：単語データがありません")
            }else if (selectedpartofspeech?.partsOfSpeechName.isEmpty)! || selectedpartofspeech?.partsOfSpeechName == notSelectedPartOfSpeech {
                showAlert(errormessage: "品詞が選択されていません")
            }else if (textField.text?.isEmpty)! {
                showAlert(errormessage: "訳文が入力されていません")
            }else{
                let realm: Realm = try! Realm()
                var result = realm.objects(WordData.self).filter("word == %@ && partofspeech == %@",mean?.word,selectedpartofspeech)
                if newMeanFlag! {
                    //
                    if result.count > 0 {
                        showAlert(errormessage: "エラー：同じ品詞での訳文が既にあります")
                    }else{
                        try! realm.write {
                            let newWordData = WordData(value: ["word" : mean?.word!,
                                                               "partofspeech" : selectedpartofspeech!,
                                                               "mean" : textField.text!])
                            realm.add(newWordData)
                            performSegue(withIdentifier: "returnToConfigureWordViewController",sender: nil)
                        }
                    }
                }else{
                    if (mean?.partofspeech != selectedpartofspeech) && result.count > 0 {
                        showAlert(errormessage: "エラー：同じ品詞での訳文が既にあります")
                    }else{
                        //編集した意味でWordDataを更新
                        try! realm.write{
                            //上書き更新
                            let toupdatemean = realm.objects(WordData.self).filter("word == %@",mean?.word! as Any)
                                    .filter("partofspeech == %@",mean?.partofspeech! as Any)[0]
                            toupdatemean.partofspeech = selectedpartofspeech
                            toupdatemean.mean = textField.text!
                        }
                        performSegue(withIdentifier: "returnToConfigureWordViewController",sender: nil)
                    }
                }
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnToConfigureWordViewController") {
            let configureWordVC: ConfigureWordViewController = (segue.destination as? ConfigureWordViewController)!
            configureWordVC.selectedword = mean?.word
        }
    }
    
    func showAlert(errormessage: String) {
        // アラートを作成
        let alert = UIAlertController(
            title: "エラー",
            message: errormessage,
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
}
