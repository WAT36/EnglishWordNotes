//
//  ConfigureTestOfWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/17.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ConfigureTestOfWordNoteBookViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet var testOrderby: UIPickerView!
    @IBOutlet var testOrderAscDesc: UISegmentedControl!
    @IBOutlet var minLevel: UITextField!
    @IBOutlet var maxLevel: UITextField!
    @IBOutlet var testForm: UISegmentedControl!
    @IBOutlet var questionNum: UITextField!

    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance

    let orderlist: [String] = ["条件なし","登録順","名前順","レベル順","正解率順"]
    var selectedorderlist: String?
    
    var wordnotebook: WordNoteBook? //singleton適用によっては削除
    
    //検索結果の単語リスト
    var wordNoteList: [WordNote] = []
    
    //検索条件のリスト
    var querylist: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate設定
        testOrderby.delegate = self
        testOrderby.dataSource = self

        // ボタンを選択中にする場所を指定
        testOrderAscDesc.selectedSegmentIndex = 0
        testForm.selectedSegmentIndex = 0
        // ボタン選択時にボタンを選択状態にするかどうかの設定
        testOrderAscDesc.isMomentary = false
        testForm.isMomentary = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //キーボード外タップしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return orderlist.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return orderlist[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        selectedorderlist = orderlist[row]
    }
    
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnToConfigureWordNoteViewController",sender: nil)
        }else if(sender.tag == 1){
            //条件をもとにテストに出す英単語を取得
            makeTest()
            
            if(wordNoteList.count == 0){
                //検索結果無し、エラーアラート出して戻させる
                aa.showErrorAlert(vc: self, m: "検索結果がありません")
            }else if(testForm.selectedSegmentIndex == 0){
                performSegue(withIdentifier: "toFourOptionTestFromConfigureTestOfWordNoteBookViewController", sender: nil)
            }else if(testForm.selectedSegmentIndex == 1){
                performSegue(withIdentifier: "toTestFromConfigureTestOfWordNoteBookViewController", sender: nil)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnToConfigureWordNoteViewController") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
//            cwnbVC.wordnotebook = wordnotebook //singleton適用によっては削除
        }else if(segue.identifier == "toTestFromConfigureTestOfWordNoteBookViewController"){
            let twnbVC: TestOfWordNoteBookViewController = (segue.destination as? TestOfWordNoteBookViewController)!
            twnbVC.wordnotebook = wordnotebook //singleton適用によっては削除
            twnbVC.wordNoteList = wordNoteList
        }else if(segue.identifier == "toFourOptionTestFromConfigureTestOfWordNoteBookViewController"){
            let realm: Realm = try! Realm()
            if(realm.objects(Word.self).count < 2){
                //四択テストを行えるだけの単語の数が足りてない（少なくとも正解単語１つ、不正解単語１つの２つが必要）
                //のでエラーアラート出して戻させる
                aa.showErrorAlert(vc: self, m: "単語の数が足りません。四択テスト実行には少なくとも２つ以上の単語が辞書にある必要があります")
            }else{
                let fotwnbVC: FourOptionTestOfWordNoteViewController = (segue.destination as? FourOptionTestOfWordNoteViewController)!
                fotwnbVC.wordnotebook = wordnotebook // singleton適用によっては削除
                fotwnbVC.wordNoteList = wordNoteList
            }
        }
    }
    
    //入力をもとにRealmで抽出条件文作成・実行
    func makeTest(){
        
        //データベース内に保存してあるWordnoteを取得し、検索条件のリストで絞る
        let realm: Realm = try! Realm()
//        var results = realm.objects(WordNote.self).filter("wordnotebook.wordNoteBookId = %@",wordnotebook?.wordNoteBookId)
        var results = realm.objects(WordNote.self).filter("wordnotebook.wordNoteBookId = %@",singleton.getWordNoteBook().wordNoteBookId)

        //入力されたレベルの間の単語のみ抽出（入力なければ無視）
        if(!(minLevel.text?.isEmpty)!){
            results = results.filter("word.level >= " + minLevel.text!)
        }
        if(!(maxLevel.text?.isEmpty)!){
            results = results.filter("word.level <= " + maxLevel.text!)
        }

        //昇順か降順か
        let isAsc = (testOrderAscDesc.selectedSegmentIndex == 1) ? false : true
        
        switch selectedorderlist{
        case orderlist[0]:
            print()
        case orderlist[1]:
            results = results.sorted(byKeyPath: "wordidx", ascending: isAsc)
        case orderlist[2]:
            results = results.sorted(byKeyPath: "word.wordName", ascending: isAsc)
        case orderlist[3]:
            results = results.sorted(byKeyPath: "word.level", ascending: isAsc)
        case orderlist[4]:
            results = results.sorted(byKeyPath: "word.accuracyRate", ascending: isAsc)
        default:
            print()
        }
        
        wordNoteList = Array(results)

        //出題個数が指定されている場合はその個数分だけ取得
        if(!(questionNum.text?.isEmpty)!){
            let questionNum = Int(self.questionNum.text!)
            if(0 < questionNum! && questionNum! < wordNoteList.count){
                wordNoteList = wordNoteList.prefix(questionNum!).map{$0}
            }
        }
    }
}
