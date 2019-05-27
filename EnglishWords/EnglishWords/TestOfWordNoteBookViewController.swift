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

class TestOfWordNoteBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var word: UILabel!
    @IBOutlet var wordNote: UILabel!
    @IBOutlet var count: UILabel!
    
    @IBOutlet var table:UITableView!

    var nowWord: Word?
    var wordIdx: Int = 0
    var wordnotebook: WordNoteBook?
    var nowWordDataList: [WordData] = []
    
    //検索条件のリスト
    var queryList: [String] = []
    
    //検索結果の単語リスト
    var wordNoteList: [WordNote] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース内に保存してあるWordnoteを取得し、検索条件のリストで絞る
        let realm: Realm = try! Realm()
        var results = realm.objects(WordNote.self).filter("wordnotebook.wordNoteBookId = %@",wordnotebook?.wordNoteBookId)
            .sorted(byKeyPath: "wordidx", ascending: true)
        for i in 0..<queryList.count {
            results = results.filter(queryList[i])
        }
        wordNoteList = Array(results)
        if(wordNoteList.count == 0){
            //検索結果無し、エラーアラート出して戻させる
            showAlert(mes: "検索結果がありません")
        }else{
            wordIdx = 0
            nowWord = wordNoteList[wordIdx].word

            word.text = wordNoteList[wordIdx].word?.wordName
            wordNote.text = wordnotebook?.wordNoteBookName
            count.text = (wordIdx + 1).description + "/" + wordNoteList.count.description

            //選択したWordからデータベース内に保存してあるWordDataを全て取得
            let realm: Realm = try! Realm()
            let results = realm.objects(WordData.self).filter("word.wordName == %@",nowWord?.wordName)
            nowWordDataList = Array(results)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returntoConfigureTestOfWordNoteBookViewController",sender: nil)
        }else if(sender.tag == 1){
            //次の単語へ
            toNextWord()
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returntoConfigureTestOfWordNoteBookViewController") {
            let ctwnbVC: ConfigureTestOfWordNoteBookViewController = (segue.destination as? ConfigureTestOfWordNoteBookViewController)!
            ctwnbVC.wordnotebook = wordnotebook
        }else if(segue.identifier == "returntoConfigureWordNoteBookViewController"){
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
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
        //partofspeech.text = oneworddata.partofspeech?.partsOfSpeechName
        let mean = cell.viewWithTag(2) as! UILabel
        mean.numberOfLines = 0
        //mean.text = oneworddata.mean
        //cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        
        partofspeech.text = ""
        mean.text = "?"
        mean.textColor = UIColor.white
        cell.backgroundColor = UIColor.black
        
        return cell
    }
    
    //次の単語へ移る
    func toNextWord(){
        if(wordIdx >= wordNoteList.count - 1){
            //テスト終了
            testEndDispAlert()
        }else{
            wordIdx += 1
            nowWord = wordNoteList[wordIdx].word
            
            word.text = wordNoteList[wordIdx].word?.wordName
            wordNote.text = wordnotebook?.wordNoteBookName
            count.text = (wordIdx + 1).description + "/" + wordNoteList.count.description
            
            //選択したWordからデータベース内に保存してあるWordDataを全て取得
            let realm: Realm = try! Realm()
            let results = realm.objects(WordData.self).filter("word.wordName == %@",nowWord?.wordName)
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
    
    // 最後の単語が終わった時にアラートを表示するメソッド
    @IBAction func testEndDispAlert() {
        
        //アラートの設定
        let alert: UIAlertController = UIAlertController(title: "テストが終了しました", message: "単語帳設定画面へ戻ります", preferredStyle:  UIAlertControllerStyle.alert)
        
        //OKボタン
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "returntoConfigureWordNoteBookViewController", sender: nil)
        })
        
        //UIAlertControllerにActionを追加
        alert.addAction(okAction)
        
        //アラートを表示
        present(alert, animated: true, completion: nil)
    }
    
    
    //アラートを出すメソッド
    func showAlert(mes: String) {
        // アラートを作成
        let alert = UIAlertController(
            title: "エラー",
            message: mes,
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
}
