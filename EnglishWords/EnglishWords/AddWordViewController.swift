//
//  AddWordViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/28.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AddWordViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet var wordtextField: UITextField!
    @IBOutlet var meantextField: UITextField!
    @IBOutlet var pickerView: UIPickerView!
    
    var partsofspeechlist: [PartsofSpeech] = []
    var selectedPartsOfSpeech: PartsofSpeech?
    var wordnotebook: WordNoteBook?
    
    var maxId:Int = -1
    
    let notSelectedPartOfSpeech: String = "---品詞を選択してください---"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate設定
        pickerView.delegate = self
        pickerView.dataSource = self
        
        wordtextField.placeholder = "単語を入力してください"
        meantextField.placeholder = "訳文を入力してください"
        
        //データベース内に保存してあるPartsofSpeechを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(PartsofSpeech.self)
        partsofspeechlist = Array(results)
        //品詞PickerViewに初期値用データを挿入
        partsofspeechlist.insert(PartsofSpeech(value: ["partsOfSpeechId": -1,
                                                        "partsOfSpeechName": notSelectedPartOfSpeech,
                                                        "createdDate": Date()]), at: 0)
        selectedPartsOfSpeech = partsofspeechlist[0]
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
        selectedPartsOfSpeech = partsofspeechlist[row]
    }
    
    @IBAction func buttonTapped(sender : UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "ReturnConfigureWordNoteBookViewContoller",sender: nil)
        }else if(sender.tag == 1){
            if wordtextField.text!.isEmpty {
                showAlert(errormessage: "単語名が入力されていません")
            }else if meantextField.text!.isEmpty {
                showAlert(errormessage: "訳文が入力されていません")
            }else if (selectedPartsOfSpeech?.partsOfSpeechName.isEmpty)! || selectedPartsOfSpeech?.partsOfSpeechName == notSelectedPartOfSpeech {
                showAlert(errormessage: "品詞が選択されていません")
            }else{
                
                //Realm、既に同じ単語が登録されてないか確認
                let realm = try! Realm()
                let results = realm.objects(Word.self).filter("wordName = %@",wordtextField.text!)
                let cardresults = realm.objects(WordNote.self).filter("wordnotebook == %@",wordnotebook!)
                if cardresults.count == 0 {
                    maxId = 0
                }else{
                    maxId = cardresults.value(forKeyPath: "@max.wordidx")! as! Int
                }
                
                print("単語名("+wordtextField.text!+"),")
                print("訳文("+meantextField.text!+"),")
                print("品詞("+(selectedPartsOfSpeech?.partsOfSpeechName)!+")")
                print(results.count)
                
                if results.count > 0 {
                    //既に同じ英単語が辞書に登録されているためエラー出させる
                    showAlert(errormessage: "既に同じ英単語が辞書にあります")
                }else{
                    performSegue(withIdentifier: "ToConfigureWordNoteBookViewContoller",sender: nil)
                }
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ReturnConfigureWordNoteBookViewContoller"){
            let cwnbVC2: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            // ConfigureWordNoteBookViewControllerのwordnotebookに設定している単語帳を設定
            cwnbVC2.wordnotebook = wordnotebook
            
        }else if (segue.identifier == "ToConfigureWordNoteBookViewContoller") {
            let cwnbVC2: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            
            //Realm、単語を登録
            let realm = try! Realm()

            let newword = Word(value: ["wordName": wordtextField.text!,
                                        "createdDate": Date()])
            let newworddata = WordData(value: ["word": newword,
                                                "partofspeech": selectedPartsOfSpeech!,
                                                "mean": meantextField.text!,
                                                "source": "出典（未実装）",
                                                "example": "例文(未実装)"])
            try! realm.write {
                    realm.add([newword])
                    realm.add([newworddata])
                    realm.add([WordNote(value: ["wordnotebook": wordnotebook!,
                                                "worddata": newworddata,
                                                "wordidx": maxId,
                                                "registereddate": Date()])])
                    
            }
            
            // ConfigureWordNoteBookViewControllerのwordnotebookに設定している単語帳を設定
            cwnbVC2.wordnotebook = wordnotebook
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
