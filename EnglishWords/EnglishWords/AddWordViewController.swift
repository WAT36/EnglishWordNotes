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
    var selectedPartsOfSpeech = ""
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
        print(partsofspeechlist)
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
        selectedPartsOfSpeech = partsofspeechlist[row].partsOfSpeechName
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        let button = sender as? UIButton
        if button!.tag == 0 {
            performSegue(withIdentifier: "ToConfigureWordNoteBookViewContoller",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToConfigureWordNoteBookViewContoller") {
            let cwnbVC2: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            // ConfigureWordNoteBookViewControllerのwordnotebookに設定している単語帳を設定
            cwnbVC2.wordnotebook = wordnotebook
        }
    }
}
