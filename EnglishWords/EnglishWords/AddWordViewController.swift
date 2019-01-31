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
    
    @IBAction func buttonTapped(sender : AnyObject) {
        performSegue(withIdentifier: "ToConfigureWordNoteBookViewContoller",sender: nil)
        
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToConfigureWordNoteBookViewContoller") {
            let cwnbVC2: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            
            //Realm、既に同じ単語が登録されてないか確認
            let realm = try! Realm()
            let results = realm.objects(Word.self).filter("wordName = '%@'",wordtextField.text!)
            let cardresults = realm.objects(WordNote.self).filter("wordnotebook == %@",wordnotebook!)
            var maxId:Int
            if cardresults.count == 0 {
                maxId = 0
            }else{
                maxId = cardresults.value(forKeyPath: "@max.wordidx")! as! Int
            }
            
            if results.count > 0 {
                //エラー出させる
                print("エラー：既に同じ名前の英単語が辞書にある")
            }else{
                print(maxId)
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
            }
            
            // ConfigureWordNoteBookViewControllerのwordnotebookに設定している単語帳を設定
            cwnbVC2.wordnotebook = wordnotebook
        }
    }
}
