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
    
    //訳文設定画面のパラメータ保持用変数
    var mean: WordData?
    var newMeanFlag: Bool?
    
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
                showAlert(errormessage: "出典が選択されていません")
            }else if((mean?.source.contains(selectedsource!))!){
                showAlert(errormessage: "選択した出典は既に選択した単語データに登録されています")
            }else{
                //Realm、出典を新規登録
                let realm = try! Realm()
                try! realm.write {
                    mean?.source.append(selectedsource!)
                }
                performSegue(withIdentifier: "returnToConfigureMeanViewController",sender: nil)
            }
            
        }else if(sender.tag == 2){
            //入力した出典を追加する　ボタン
            
            if (sourcetext.text?.isEmpty)! {
                showAlert(errormessage: "登録する出典が入力されていません")
            }else{
                let newsource = Source(value: ["sourceName" : sourcetext.text!,
                                               "createdDate": Date()])
                if(sourcelist.contains(newsource)){
                    showAlert(errormessage: "その出典は既に既存の出典データに登録されています")
                }else if((mean?.source.contains(newsource))!){
                    showAlert(errormessage: "その出典は既に選択した単語データに登録されています")
                }else{

                    //Realm、出典を新規登録
                    let realm = try! Realm()
                    try! realm.write {
                        mean?.source.append(newsource)
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
            let configureMeanVC: ConfigureMeanViewController = (segue.destination as? ConfigureMeanViewController)!
            configureMeanVC.mean = mean
            configureMeanVC.newMeanFlag = newMeanFlag
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
