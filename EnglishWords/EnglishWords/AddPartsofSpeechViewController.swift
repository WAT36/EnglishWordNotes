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

class AddPartsofSpeechViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var table:UITableView!

    let singleton :Singleton = Singleton.sharedInstance
    let aa = AlertAction()
    
    var partsofSpeechList: [PartsofSpeech] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データベース内に保存してあるPartOfSpeechを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(PartsofSpeech.self).sorted(byKeyPath: "partsOfSpeechId", ascending: true)
        partsofSpeechList = Array(results)

        label.text = "新しく追加する品詞名を記入して下さい"
        
        // textField の情報を受け取るための delegate を設定
        textField.delegate = self
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return partsofSpeechList.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                                 for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        let partsofSpeech = partsofSpeechList[indexPath.row]
        let label1 = cell.viewWithTag(1) as! UILabel
        label1.numberOfLines = 0
        label1.text = partsofSpeech.partsOfSpeechName
        cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        //ラベルをセル内で上下中央揃えにする
        label1.baselineAdjustment = UIBaselineAdjustment.alignCenters
            
        return cell
    }
    
    // Cell の高さを３０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
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
                aa.showErrorAlert(vc: self, m: "品詞名が入力されていません")
            }else if(self.checkRegisteredPartOfSpeech(partsofspeechname: (textField.text?.trimmingCharacters(in: .whitespaces))!)){
                aa.showErrorAlert(vc: self, m: "既に同じ品詞名が登録されています")
            }else{
                
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
                
                performSegue(withIdentifier: singleton.getStringValue(key: "Segue.addPartsOfSpeech.top"),sender: nil)
            }
        }else if(sender.tag == 1){
            performSegue(withIdentifier: singleton.getStringValue(key: "Segue.addPartsOfSpeech.top"),sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == singleton.getStringValue(key: "Segue.addPartsOfSpeech.top")) {
            let _: ViewController = (segue.destination as? ViewController)!
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

