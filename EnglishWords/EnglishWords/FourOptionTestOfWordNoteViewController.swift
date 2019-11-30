//
//  FourOptionTestOfWordNoteViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/07/09.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class FourOptionTestOfWordNoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var word: UILabel!
    @IBOutlet var wordNote: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var clearLabel: UILabel!
    @IBOutlet var rate: UILabel!

    @IBOutlet var table:UITableView!
    
    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance
    let infoList = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Constant", ofType: "plist")!)

    var wordIdx: Int = 0
    var nowWordDataList: [WordData] = []

    //検索結果の単語リスト(テスト設定画面で取得)
    var wordNoteList: [WordNote] = []

    //検索結果の単語リスト内の正解・不正解単語の単語データ
    var correctWordDataList: [WordData] = []
    var incorrectWordDataList: [WordData] = []
    //セルに表示する単語データ（選択肢）
    var displayWordDataList: [WordData] = []
    //正解の選択肢のインデックス
    var correctIndex: Int = 0
    
    //何択問題でやるかの指定
    let optionNum = 4

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

            //選択したWordからデータベース内に保存してあるWordDataを取得
            let realm: Realm = try! Realm()
            //正解データ
            var results = realm.objects(WordData.self).filter("word.wordName == %@",singleton.getNowTestingWord().wordName)
            correctWordDataList = Array(results)
            //不正解データ
            results = realm.objects(WordData.self).filter("word.wordName != %@",singleton.getNowTestingWord().wordName)
            incorrectWordDataList = Array(results)
            //正解の選択肢
            correctIndex = Int.random(in: 0..<optionNum)
            //選択肢作成
            for i in 0..<optionNum {
                if(i == correctIndex){
                    displayWordDataList.append(correctWordDataList[Int.random(in: 0..<correctWordDataList.count)])
                }else{
                    displayWordDataList.append(incorrectWordDataList[Int.random(in: 0..<incorrectWordDataList.count)])
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: infoList!.value(forKeyPath: "fourOptionTestOfWordNote.configureTestOfWordNoteBook") as! String,sender: nil)
        }else if(sender.tag == 1){
            //次の単語へ
            toNextWord()
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        singleton.saveNowTestingWord(ntw: Word())
        if (segue.identifier == infoList!.value(forKeyPath: "fourOptionTestOfWordNote.configureTestOfWordNoteBook") as? String) {
            let _: ConfigureTestOfWordNoteBookViewController = (segue.destination as? ConfigureTestOfWordNoteBookViewController)!
        }else if(segue.identifier == infoList!.value(forKeyPath: "fourOptionTestOfWordNote.configureWordNoteBook") as? String){
            let _: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
        }
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return optionNum
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        // 単語の訳文を表示
        let oneworddata = displayWordDataList[indexPath.row]
        let partofspeech = cell.viewWithTag(1) as! UILabel
        partofspeech.numberOfLines = 0
        partofspeech.text = oneworddata.partofspeech?.partsOfSpeechName
        let mean = cell.viewWithTag(2) as! UILabel
        mean.numberOfLines = 0
        mean.text = oneworddata.mean
        mean.textColor = UIColor.black
        mean.lineBreakMode = .byCharWrapping
        cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.5)
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == correctIndex {
            //正解
            let cell = table.cellForRow(at: IndexPath(item: correctIndex, section: 0))
            let label = (cell?.viewWithTag(2) as! UILabel)
            label.textColor = UIColor.red
            clearLabel.text = "正解!!↑次へ"
            clearLabel.textColor = UIColor.red
        }else{
            //不正解
            let cell = table.cellForRow(at: IndexPath(item: correctIndex, section: 0))
            let label = (cell?.viewWithTag(2) as! UILabel)
            label.textColor = UIColor.red
            clearLabel.text = "不正解!!↑次へ"
            clearLabel.textColor = UIColor.black
        }
        //一回タップしたので他のセルをタップ不可にする（再度回答するのを防ぐ）
        self.table.allowsSelection = false
    }
    
    //次の単語へ移る
    func toNextWord(){
        
        //正答数と回答数を記録（Wordを取得して更新）
        let realm = try! Realm()
        let results = realm.objects(Word.self).filter("wordName == %@",singleton.getNowTestingWord().wordName).first

        try! realm.write {
            results?.numOfAnswer = (singleton.getNowTestingWord().numOfAnswer) + 1
            if(clearLabel.text == "正解!!↑次へ"){
                //訳文を全部正答したなら正答数も+1
                results?.numOfCorrect = (singleton.getNowTestingWord().numOfCorrect) + 1
            }
            results?.accuracyRate = Double((results?.numOfCorrect)!) / Double((results?.numOfAnswer)!)
        }

        //隠しラベル非点灯へ
        clearLabel.text = ""
        clearLabel.textColor = UIColor.white
        
        //セルのタップを可能にする
        self.table.allowsSelection = true
        
        if(wordIdx >= wordNoteList.count - 1){
            //テスト終了
            aa.testEndDispAlert(vc: self, identifier: infoList!.value(forKeyPath: "fourOptionTestOfWordNote.configureWordNoteBook") as! String)
        }else{
            wordIdx += 1
            singleton.saveNowTestingWord(ntw: wordNoteList[wordIdx].word!)
            
            word.text = wordNoteList[wordIdx].word?.wordName
            wordNote.text = singleton.getWordNoteBook().wordNoteBookName
            count.text = (wordIdx + 1).description + "/" + wordNoteList.count.description
            rate.text = "(" + (singleton.getNowTestingWord().numOfCorrect.description) + "/" + (singleton.getNowTestingWord().numOfAnswer.description) + ")"
            
            //選択したWordからデータベース内に保存してあるWordDataを取得
            let realm: Realm = try! Realm()
            //正解データ
            var results = realm.objects(WordData.self).filter("word.wordName == %@",singleton.getNowTestingWord().wordName)
            correctWordDataList = Array(results)
            //不正解データ
            results = realm.objects(WordData.self).filter("word.wordName != %@",singleton.getNowTestingWord().wordName)
            incorrectWordDataList = Array(results)
            //正解の選択肢
            correctIndex = Int.random(in: 0..<optionNum)
            //選択肢作成
            displayWordDataList.removeAll()
            for i in 0..<optionNum {
                if(i == correctIndex){
                    displayWordDataList.append(correctWordDataList[Int.random(in: 0..<correctWordDataList.count)])
                }else{
                    displayWordDataList.append(incorrectWordDataList[Int.random(in: 0..<incorrectWordDataList.count)])
                }
            }
            
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
