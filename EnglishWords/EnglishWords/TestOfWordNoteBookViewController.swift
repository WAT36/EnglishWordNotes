//
//  TestOfWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/18.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TestOfWordNoteBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    @IBOutlet var word: UILabel!
    @IBOutlet var wordNote: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var clearLabel: UILabel!
    @IBOutlet var rate: UILabel!
    
    @IBOutlet var table:UITableView!
    @IBOutlet var answerMeanTextField:UITextField!

    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance
    var wordIdx: Int = 0
    var nowWordDataList: [WordData] = []
    
    var numOfClear: [Int] = []  //正答した訳文のインデックス
    
    //検索条件のリスト
    var queryList: [String] = []
    
    //検索結果の単語リスト
    var wordNoteList: [WordNote] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearLabel.textColor = UIColor.white
        
        if(wordNoteList.count == 0){
            //検索結果無し、エラーアラート出して戻させる
            aa.showErrorAlert(vc: self, m: "検索結果がありません")
        }else{
            wordIdx = 0
            singleton.saveNowTestingWord(ntw: wordNoteList[wordIdx].word!)

            word.text = wordNoteList[wordIdx].word?.wordName
            wordNote.text = singleton.getWordNoteBook().wordNoteBookName
            count.text = (wordIdx + 1).description + "/" + wordNoteList.count.description
            rate.text = "(" + (singleton.getNowTestingWord().numOfCorrect.description) + "/" + (singleton.getNowTestingWord().numOfAnswer.description) + ")"

            //選択したWordからデータベース内に保存してあるWordDataを全て取得
            let realm: Realm = try! Realm()
            let results = realm.objects(WordData.self).filter("word.wordName == %@",singleton.getNowTestingWord().wordName)
            nowWordDataList = Array(results)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //キーボード外タップしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returntoConfigureTestOfWordNoteBookViewController",sender: nil)
        }else if(sender.tag == 1){
            //次の単語へ
            toNextWord()
        }else if(sender.tag == 2){
            if((answerMeanTextField.text?.isEmpty)!){
                //エラーアラート出させて戻る
                aa.showErrorAlert(vc: self, m: "入力がありません")
            }else{
                //入力したテキストを元にテーブル更新
                table.reloadData()
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        singleton.saveNowTestingWord(ntw: Word()) //現出題単語リセット
        if (segue.identifier == "returntoConfigureTestOfWordNoteBookViewController") {
            let _: ConfigureTestOfWordNoteBookViewController = (segue.destination as? ConfigureTestOfWordNoteBookViewController)!
        }else if(segue.identifier == "returntoConfigureWordNoteBookViewController"){
            let _: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
        }
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return nowWordDataList.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        let oneworddata = nowWordDataList[indexPath.row]
        let partofspeech = cell.viewWithTag(1) as! UILabel
        partofspeech.numberOfLines = 0
        let mean = cell.viewWithTag(2) as! UILabel
        mean.numberOfLines = 0
        mean.lineBreakMode = .byCharWrapping
        
        if(numOfClear.contains(indexPath.row) || oneworddata.mean.contains((answerMeanTextField.text)!)){
            partofspeech.text = oneworddata.partofspeech?.partsOfSpeechName
            mean.text = oneworddata.mean
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            if(!numOfClear.contains(indexPath.row)){
                numOfClear.append(indexPath.row)
            }
        }else{
            partofspeech.text = ""
            mean.text = "?"
            mean.textColor = UIColor.white
            cell.backgroundColor = UIColor.black
        }
        
        if(nowWordDataList.count <= numOfClear.count){
            //訳文を全部正答した
            //隠しラベル点灯
            clearLabel.textColor = UIColor.red
        }
        
        return cell
    }
    
    //次の単語へ移る
    func toNextWord(){
        
        //隠しラベル非点灯へ
        clearLabel.textColor = UIColor.white
        
        //正答数と回答数を記録（Wordを取得して更新）
        let realm = try! Realm()
        let results = realm.objects(Word.self).filter("wordName == %@",singleton.getNowTestingWord().wordName).first

        try! realm.write {
            results?.numOfAnswer = (singleton.getNowTestingWord().numOfAnswer) + 1
            if(nowWordDataList.count <= numOfClear.count){
                //訳文を全部正答したなら正答数も+1
                results?.numOfCorrect = (singleton.getNowTestingWord().numOfCorrect) + 1
            }
            results?.accuracyRate = Double((singleton.getNowTestingWord().numOfCorrect) + 1) / Double((singleton.getNowTestingWord().numOfAnswer) + 1)
        }
        
        //正答した訳文のインデックスをクリア
        numOfClear = []

        if(wordIdx >= wordNoteList.count - 1){
            //テスト終了
            aa.testEndDispAlert(vc: self, identifier: "returntoConfigureWordNoteBookViewController")
        }else{
            wordIdx += 1
            singleton.saveNowTestingWord(ntw: wordNoteList[wordIdx].word!)

            word.text = wordNoteList[wordIdx].word?.wordName
            wordNote.text = singleton.getWordNoteBook().wordNoteBookName
            count.text = (wordIdx + 1).description + "/" + wordNoteList.count.description
            rate.text = "(" + (singleton.getNowTestingWord().numOfCorrect.description) + "/" + (singleton.getNowTestingWord().numOfAnswer.description) + ")"

            //選択したWordからデータベース内に保存してあるWordDataを全て取得
            let realm: Realm = try! Realm()
            let results = realm.objects(WordData.self).filter("word.wordName == %@",singleton.getNowTestingWord().wordName)
            nowWordDataList = Array(results)
            
            //テーブル更新
            table.reloadData()
        }
    }
    
    // tableのCell の高さを９０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}
