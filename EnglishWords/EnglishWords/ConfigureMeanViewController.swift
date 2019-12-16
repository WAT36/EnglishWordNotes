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
    
    var partsofspeechlist: [PartsofSpeech] = []
    var selectedpartofspeech: PartsofSpeech?
    var selectedsource: Source?
    
    @IBOutlet var partofspeeches: UIPickerView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var sourcetable:UITableView!
    @IBOutlet var exampleEn:UITextView!
    @IBOutlet var exampleJa:UITextView!
    
    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance
    let notSelectedPartOfSpeech: String = Singleton.sharedInstance.getStringValue(key: "Menu.selectPartsOfSpeech")
    
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
        if !singleton.getIsAddingNewWordData() {
            textView.text = singleton.getWordData().mean
        }
        
        //テキストビューの枠線設定
        textView.layer.borderColor = UIColor.black.cgColor  //色
        textView.layer.borderWidth = 1.0                    //幅
        
        //例文設定・テキストビューの枠線などの設定
        exampleEn.text = singleton.getWordData().example_q
        exampleJa.text = singleton.getWordData().example_a
        exampleEn.layer.borderColor = UIColor.black.cgColor  //色
        exampleEn.layer.borderWidth = 1.0                    //幅
        exampleJa.layer.borderColor = UIColor.black.cgColor  //色
        exampleJa.layer.borderWidth = 1.0                    //幅
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
        return singleton.getWordData().source.count + 1
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        if indexPath.row < singleton.getWordData().source.count {
            // Tag番号  で UILabel インスタンスの生成
            let oneworddata = singleton.getWordData().source[indexPath.row].sourceName
            let sourcename = cell.viewWithTag(1) as! UILabel
            sourcename.numberOfLines = 0
            sourcename.text = oneworddata
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        } else {
            let addsourcecell = cell.viewWithTag(1) as! UILabel
            addsourcecell.numberOfLines = 0
            addsourcecell.text = singleton.getStringValue(key: "Menu.addSource")
            cell.backgroundColor = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 0.5)
        }
        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < singleton.getWordData().source.count {
            //出典のセルを選択してもとりあえず今は何もしないでおく
        }else{
            // AddSourceViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: singleton.getStringValue(key: "Segue.configureMean.AddSource"), sender: nil)
        }
    }
    
    //テーブルでセル毎にスワイプを有効、無効にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
            selectedsource = singleton.getWordData().source[indexPath.row]
            //Realmデータベースからも削除
            let realm = try! Realm()
            try! realm.write {
                singleton.getWordData().source.remove(at: (singleton.getWordData().source.index(of: selectedsource!))!)
            }
            //テーブルから削除
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func buttonTapped(sender : AnyObject) {
        if(sender.tag == 0){
            performSegue(withIdentifier: singleton.getStringValue(key: "Segue.configureMean.configureWord") ,sender: nil)
        }else if(sender.tag == 1){
            if(singleton.getWord().wordName == " "){
                aa.showErrorAlert(vc: self, m: "単語データがありません")
            }else if (selectedpartofspeech?.partsOfSpeechName.isEmpty)! || selectedpartofspeech?.partsOfSpeechName == notSelectedPartOfSpeech {
                aa.showErrorAlert(vc: self, m: "品詞が選択されていません")
            }else if (textView.text?.isEmpty)! {
                aa.showErrorAlert(vc: self, m: "訳文が入力されていません")
            }else{
                let realm: Realm = try! Realm()
                if singleton.getIsAddingNewWordData() {
                    try! realm.write {
                        let newWordData = WordData(value: ["word" : singleton.getWordData().word!,
                                                           "partofspeech" : selectedpartofspeech!,
                                                           "mean" : textView.text!.trimmingCharacters(in: .whitespaces),
                                                           "example_q" : exampleEn.text!.trimmingCharacters(in: .whitespaces),
                                                           "example_a" : exampleJa.text!.trimmingCharacters(in: .whitespaces)])
                        realm.add(newWordData)
                        performSegue(withIdentifier: singleton.getStringValue(key: "Segue.configureMean.configureWord"),sender: nil)
                    }
                }else{
                    //編集した意味でWordDataを更新
                    try! realm.write{
                        //上書き更新
                        let toupdatemean = realm.objects(WordData.self).filter("word == %@",singleton.getWordData().word as Any).filter("meanidx == %@",singleton.getWordData().meanidx as Any).first
                        toupdatemean!.partofspeech = selectedpartofspeech
                        toupdatemean!.mean = textView.text!.trimmingCharacters(in: .whitespaces)
                        toupdatemean!.example_q = exampleEn.text!.trimmingCharacters(in: .whitespaces)
                        toupdatemean!.example_a = exampleJa.text!.trimmingCharacters(in: .whitespaces)
                    }
                    performSegue(withIdentifier: singleton.getStringValue(key: "Segue.configureMean.configureWord"),sender: nil)
                }
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == singleton.getStringValue(key: "Segue.configureMean.configureWord")) {
            //現在選択している訳文の情報を削除
            singleton.saveWordData(wd: WordData())
            //訳文新規追加かを示すsingleton中のフラグをリセット
            singleton.saveIsAddingNewWordData(ianwd: false)
            let _: ConfigureWordViewController = (segue.destination as? ConfigureWordViewController)!
        }else if(segue.identifier == singleton.getStringValue(key: "Segue.configureMean.AddSource")){
            let _: AddSourceViewController = (segue.destination as? AddSourceViewController)!
        }
    }
}
