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
    
    var mean: WordData? //singleton適用によっては削除
    var partsofspeechlist: [PartsofSpeech] = []
    var selectedpartofspeech: PartsofSpeech?
    var newMeanFlag: Bool?
    var selectedsource: Source?
    var wordnote: WordNote? //singleton適用によっては削除
    
    @IBOutlet var partofspeeches: UIPickerView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var sourcetable:UITableView!
    @IBOutlet var exampleEn:UILabel!
    @IBOutlet var exampleJa:UILabel!
    
    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance
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
        
        //テキストビューの初期値に登録されてある意味
        if !newMeanFlag! {
//            textView.text = mean?.mean //singleton適用によっては削除
            textView.text = singleton.getWordData().mean
        }
        
        //テキストビューの枠線設定
        textView.layer.borderColor = UIColor.black.cgColor  //色
        textView.layer.borderWidth = 1.0                    //幅
        
        //例文設定
//        exampleEn.text = mean?.example_q
//        exampleJa.text = mean?.example_a //singleton適用によっては削除
        exampleEn.text = singleton.getWordData().example_q
        exampleJa.text = singleton.getWordData().example_a
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
//        return (mean?.source.count)! + 1 //singleton適用によっては削除
        return singleton.getWordData().source.count + 1
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
//        if indexPath.row < (mean?.source.count)! { //singleton適用によっては削除
        if indexPath.row < singleton.getWordData().source.count {
            // Tag番号  で UILabel インスタンスの生成
//            let oneworddata = mean!.source[indexPath.row].sourceName
            let oneworddata = singleton.getWordData().source[indexPath.row].sourceName
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
//        if indexPath.row < (mean?.source.count)! {
        if indexPath.row < singleton.getWordData().source.count {
            //出典のセルを選択してもとりあえず今は何もしないでおく
        }else{
            // AddSourceViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toAddSourceViewController", sender: nil)
        }
    }
    
    //テーブルでセル毎にスワイプを有効、無効にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.row < (mean?.source.count)! {
        if indexPath.row < singleton.getWordData().source.count {
            return true
        }else{
            return false
        }
    }
    
    //選択したセルでスワイプすると削除される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //選択したセルの出典を記録
//            selectedsource = mean!.source[indexPath.row]
            selectedsource = singleton.getWordData().source[indexPath.row]
            //Realmデータベースからも削除
            let realm = try! Realm()
            try! realm.write {
//                mean?.source.remove(at: (mean?.source.index(of: selectedsource!))!)
                singleton.getWordData().source.remove(at: (mean?.source.index(of: selectedsource!))!)
            }
            //テーブルから削除
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func buttonTapped(sender : AnyObject) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnToConfigureWordViewController",sender: nil)
        }else if(sender.tag == 1){
//            if(mean?.word == nil){
            if(singleton.getWord().wordName == " "){
                aa.showErrorAlert(vc: self, m: "単語データがありません")
            }else if (selectedpartofspeech?.partsOfSpeechName.isEmpty)! || selectedpartofspeech?.partsOfSpeechName == notSelectedPartOfSpeech {
                aa.showErrorAlert(vc: self, m: "品詞が選択されていません")
            }else if (textView.text?.isEmpty)! {
                aa.showErrorAlert(vc: self, m: "訳文が入力されていません")
            }else{
                let realm: Realm = try! Realm()
                if newMeanFlag! {
                    try! realm.write {
//                        let newWordData = WordData(value: ["word" : mean?.word!,
//                                                               "partofspeech" : selectedpartofspeech!,
//                                                               "mean" : textView.text!])
                        let newWordData = WordData(value: ["word" : singleton.getWordData().word!,
                                                           "partofspeech" : selectedpartofspeech!,
                                                           "mean" : textView.text!])
                        realm.add(newWordData)
                        performSegue(withIdentifier: "returnToConfigureWordViewController",sender: nil)
                    }
                }else{
                    //編集した意味でWordDataを更新
                    try! realm.write{
                        //上書き更新
//                        let toupdatemean = realm.objects(WordData.self).filter("word == %@",mean?.word! as Any).filter("meanidx == %@",mean?.meanidx as Any).first
                        let toupdatemean = realm.objects(WordData.self).filter("word == %@",singleton.getWordData().word as Any).filter("meanidx == %@",singleton.getWordData().meanidx as Any).first
                        toupdatemean!.partofspeech = selectedpartofspeech
                        toupdatemean!.mean = textView.text!
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
            configureWordVC.selectedword = mean?.word //singleton適用によっては削除
            
            //singleton適用によっては削除
            if wordnote != nil {
                configureWordVC.wordnote = wordnote
            }
        }else if(segue.identifier == "toAddSourceViewController"){
            let addSourceVC: AddSourceViewController = (segue.destination as? AddSourceViewController)!
            addSourceVC.mean = mean //singleton適用によっては削除
            addSourceVC.newMeanFlag = newMeanFlag
            
            //singleton適用によっては削除
            if wordnote != nil {
                addSourceVC.wordnote = wordnote
            }
        }
    }
}
