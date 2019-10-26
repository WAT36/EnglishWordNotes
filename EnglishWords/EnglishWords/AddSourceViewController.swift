//
//  AddSourceViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/03/13.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AddSourceViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet var sources: UIPickerView!
    @IBOutlet var sourcetext: UITextField!
    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance

    var sourcelist: [Source] = []
    var selectedsource: Source?
    
    let notSelectedSource: String = "--出典を選択してください--"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate設定
        sources.delegate = self
        sources.dataSource = self
        
        //データベース内に保存してあるSourceを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(Source.self)
        sourcelist = Array(results)
        
        //品詞PickerViewに初期値用データを挿入
        sourcelist.insert(Source(value: ["sourceName": notSelectedSource,
                                        "createdDate": Date()]), at: 0)
        selectedsource = sourcelist[0]

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
        return sourcelist.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return sourcelist[row].sourceName
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        selectedsource = sourcelist[row]
    }
    
    @IBAction func buttonTapped(sender : AnyObject) {
        if(sender.tag == 0){
            //戻るボタン
            performSegue(withIdentifier: "returnToConfigureMeanViewController",sender: nil)
        }else if(sender.tag == 1){
            //選択した出典から追加する　ボタン
            
            if (selectedsource?.sourceName.isEmpty)! || selectedsource?.sourceName == notSelectedSource {
                aa.showErrorAlert(vc: self, m: "出典が選択されていません")
            }else if(singleton.getWordData().source.contains(selectedsource!)){
                aa.showErrorAlert(vc: self, m: "選択した出典は既に選択した単語データに登録されています")
            }else{
                //Realm、出典を新規登録
                let realm = try! Realm()
                try! realm.write {
                    singleton.getWordData().source.append(selectedsource!)
                }
                performSegue(withIdentifier: "returnToConfigureMeanViewController",sender: nil)
            }
            
        }else if(sender.tag == 2){
            //入力した出典を追加する　ボタン
            if (sourcetext.text?.isEmpty)! {
                aa.showErrorAlert(vc: self, m: "登録する出典が入力されていません")
            }else{
                let newsource = Source(value: ["sourceName" : sourcetext.text!,
                                               "createdDate": Date()])
                //入力した出典が既にSourceにあるかを確認する
                let realm = try! Realm()
                let results = realm.objects(Source.self).filter("sourceName == %@",sourcetext.text!)
                if(results.count > 0){
                    aa.showErrorAlert(vc: self, m: "その出典は既に既存の出典データに登録されています")
                }else if(singleton.getWordData().source.contains(newsource)){
                    aa.showErrorAlert(vc: self, m: "その出典は既に選択した単語データに登録されています")
                }else{

                    //Realm、出典を新規登録
                    let realm = try! Realm()
                    try! realm.write {
                        singleton.getWordData().source.append(newsource)
                        realm.add(newsource)
                    }
                    
                    performSegue(withIdentifier: "returnToConfigureMeanViewController", sender: nil)
                }
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnToConfigureMeanViewController") {
            let _: ConfigureMeanViewController = (segue.destination as? ConfigureMeanViewController)!
        }
    }
}
