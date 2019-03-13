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

class ConfigureMeanViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource  {
    
    var mean: WordData?
    var partsofspeechlist: [PartsofSpeech] = []
    var selectedpartofspeech: PartsofSpeech?
    var newMeanFlag: Bool?
    
    @IBOutlet var partofspeeches: UIPickerView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var sourcetable:UITableView!
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return (mean?.source.count)! + 1
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        if indexPath.row < (mean?.source.count)! {
            // Tag番号  で UILabel インスタンスの生成
            let oneworddata = mean!.source[indexPath.row].sourceName
            let sourcename = cell.viewWithTag(1) as! UILabel
            sourcename.numberOfLines = 0
            sourcename.text = oneworddata
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        } else {
            let addsourcecell = cell.viewWithTag(1) as! UILabel
            addsourcecell.numberOfLines = 0
            addsourcecell.text = "➕出典を追加する"
            cell.backgroundColor = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 0.5)
        }
        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < (mean?.source.count)! {
            //出典のセルを選択してもとりあえず今は何もしないでおく
        }else{
            // AddSourceViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toAddSourceViewController", sender: nil)
        }
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
                if newMeanFlag! {
                    try! realm.write {
                        let newWordData = WordData(value: ["word" : mean?.word!,
                                                               "partofspeech" : selectedpartofspeech!,
                                                               "mean" : textField.text!])
                        realm.add(newWordData)
                        performSegue(withIdentifier: "returnToConfigureWordViewController",sender: nil)
                    }
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
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnToConfigureWordViewController") {
            let configureWordVC: ConfigureWordViewController = (segue.destination as? ConfigureWordViewController)!
            configureWordVC.selectedword = mean?.word
        }else if(segue.identifier == "toAddSourceViewController"){
            let addSourceVC: AddSourceViewController = (segue.destination as? AddSourceViewController)!
            addSourceVC.mean = mean
            addSourceVC.newMeanFlag = newMeanFlag
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
