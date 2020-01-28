//
//  AddWordFromWebViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/02/26.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Alamofire
import Kanna

class AddWordFromWebViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var table:UITableView!
    @IBOutlet var wordtextField: UITextField!
    @IBOutlet var uiswitch: UISwitch!
    @IBOutlet var inputwordname: UILabel!
    @IBOutlet var level: UILabel!
    @IBOutlet var pronounce: UILabel!
    @IBOutlet var addWordAlert: UILabel!
    
    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance

    var inputword: String = ""
    var scrapedWord: ScrapedWord = ScrapedWord()
    var addSourceSwitch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordtextField.placeholder = singleton.getStringValue(key: "Menu.inputWord")
        
        //スイッチは最初OFF
        uiswitch.isOn = false
        
        //tableのラベルを折り返す設定
        table.estimatedRowHeight=120
        table.rowHeight=UITableViewAutomaticDimension
        
        //警告ラベルを見えなくする
        addWordAlert.textColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func switchChanged(_ sender: UISwitch){
        addSourceSwitch = sender.isOn
    }
    
    //テーブルのセルの数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scrapedWord.getWordData().count
    }
    
    //テーブルのセルの要素を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        let poslabel = cell.viewWithTag(1) as! UILabel
        poslabel.numberOfLines = 0
        poslabel.text = scrapedWord.getWordData()[indexPath.row].getPartOfSpeech()
        let meanlabel = cell.viewWithTag(2) as! UILabel
        meanlabel.numberOfLines = 0
        meanlabel.text = scrapedWord.getWordData()[indexPath.row].getMean()
        if(scrapedWord.getWordData()[indexPath.row].getExEn().isEmpty){
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
        }else{
            cell.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 0.5)
        }
        return cell
    }
    
    //指定したテーブル、セル毎にスワイプを有効、無効にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //選択したセルでスワイプすると削除される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //選択したセルの訳文を削除
            scrapedWord.removeWordData(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // TableのCell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    @IBAction func buttonTapped(sender : UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: singleton.getStringValue(key: "Segue.addWordFromWeb.configureWordNoteBook"),sender: nil)
        }else if(sender.tag == 1){
            //OKボタン
            if scrapedWord.getWordData().isEmpty {
                //登録する訳文がありません
                aa.showErrorAlert(vc: self, m: singleton.getStringValue(key: "Message.addWordFromWeb.noRegisteredMean"))
            }else if (wordtextField.text?.isEmpty)! || inputword.isEmpty {
                //単語が未入力
                aa.showErrorAlert(vc: self, m: singleton.getStringValue(key: "Message.addWordFromWeb.noInputWord"))
            }else if (self.checkRegisteredWordinWordNote(wordname: inputword)){
                //既に単語帳に登録されている
                aa.showErrorAlert(vc: self, m: singleton.getStringValue(key: "Message.addWordFromWeb.already"))
            }else if(self.checkRegisteredWordinDictionary(wordname: inputword)){
                //スクレイピングした単語が既に辞書にあるため辞書にあるデータから登録する
                self.addWordalreadyinDictionary()
                performSegue(withIdentifier: singleton.getStringValue(key: "Segue.addWordFromWeb.configureWordNoteBook"),sender: nil)
            }else{
                //スクレイピングした単語を単語帳と辞書に登録する
                self.addScrapedWord()
                performSegue(withIdentifier: singleton.getStringValue(key: "Segue.addWordFromWeb.configureWordNoteBook"),sender: nil)
            }
        }else if(sender.tag == 2){
            //Web取得開始ボタン
            if wordtextField.text!.isEmpty {
                //単語が入力されていない
                aa.showErrorAlert(vc: self, m: singleton.getStringValue(key: "Message.addWordFromWeb.noInputWord"))
            }else{
                inputword = wordtextField.text!
                inputwordname.text = wordtextField.text!
                
                //入力された単語が既に辞書に登録された単語かチェック　→ 既に辞書にあったら　※既に辞書に登録されている...  という文を表示させる
                if(self.checkRegisteredWordinDictionary(wordname: wordtextField.text!)){
                    addWordAlert.textColor = UIColor.black
                }else{
                    addWordAlert.textColor = UIColor.white
                }
                
                //スクレイピング開始
                let ws:WordScraping = WordScraping()

                //結果データをリセット
                scrapedWord = ScrapedWord()
                //スクレイピングし、結果データを格納
                scrapedWord = ws.scrapeWebsite(wordName: wordtextField.text!)
                //画面にレベルと発音記号を載せる
                level.text = scrapedWord.getLevel()
                pronounce.text = scrapedWord.getPronounce()
                //画面のテーブルビュー更新
                self.table.reloadData()
                
                
                if(scrapedWord.getErrorFlag()){
                    //ネットワークエラー、
                    aa.showErrorAlert(vc: self, m: self.singleton.getStringValue(key: "Message.addWordFromWeb.networkError"))
                }else if(scrapedWord.getWordData().isEmpty){
                    //取得結果なし
                    aa.showErrorAlert(vc: self, m: singleton.getStringValue(key: "Message.addWordFromWeb.notFoundMean"))
                }
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == singleton.getStringValue(key: "Segue.addWordFromWeb.configureWordNoteBook")) {
            let _: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
        }
    }
    
    //スクレイピングで取得したが既に辞書に登録されていた単語の場合、辞書から単語帳に登録する
    func addWordalreadyinDictionary(){
        let realm = try! Realm()
        let addWord = realm.objects(Word.self).filter("wordName == %@",inputword)
        if(addWord.count == 1){
            let cardresults = realm.objects(WordNote.self).filter("wordnotebook == %@",singleton.getWordNoteBook())
            var maxId: Int = -1
            if cardresults.count == 0 {
                maxId = 0
            }else{
                maxId = cardresults.value(forKeyPath: "@max.wordidx")! as! Int
            }
            try! realm.write {
                realm.add([WordNote(value: ["wordnotebook": singleton.getWordNoteBook(),
                                            "word": addWord.first!,
                                            "wordidx": (maxId + 1),
                                            "registereddate": Date()])])
                
                //「出典に単語帳名を追加する」スイッチがついていたら単語帳名を出典に追加させる
                if(uiswitch.isOn){
                    //単語のWordData取得
                    var results: [WordData] = Array(realm.objects(WordData.self).filter("word.wordName == %@",inputword))
                    //WordData一つ一つに出典追加
                    let source = realm.objects(Source.self).filter("sourceName ==  %@",singleton.getWordNoteBook().wordNoteBookName).first!
                    //TODO 一括更新する方法は無いか？
                    for i in 0..<results.count{
                        results[i].source.append(source)
                    }
                }
            }
        }else{
            aa.showErrorAlert(vc: self, m: singleton.getStringValue(key: "Message.addWordFromWeb.noRegisteredinDictionary"))
        }
    }
    
    //OKボタン押下後にスクレイピングした単語を単語帳と辞書に登録する
    func addScrapedWord(){
        
        //Realm
        let realm = try! Realm()
        
        //レベルを数値に変換
        var levelnum: Int
        if let temp = Int(level.text!) {
            //取得したレベルが数値ならそれを使う
            levelnum = temp
        } else {
            //レベルが取得できないならレベル無しとして-1とする
            levelnum = -1
        }
        
        //単語を新規登録する。pronounceには発音記号、levelにはレベルを書く
        let newword = Word(value: ["wordName": inputword,
                                   "createdDate": Date(),
                                   "pronounce": pronounce.text!,
                                    "level": levelnum])
        
        //現単語帳に登録するための登録番号を取得
        var maxId: Int
        let cardresults = realm.objects(WordNote.self).filter("wordnotebook == %@",singleton.getWordNoteBook())
        if cardresults.count == 0 {
            maxId = 0
        }else{
            maxId = cardresults.value(forKeyPath: "@max.wordidx")! as! Int
        }
        
        try! realm.write {
            realm.add([newword])
            realm.add([WordNote(value: ["wordnotebook": singleton.getWordNoteBook(),
                                        "word": newword,
                                        "wordidx": (maxId + 1),
                                        "registereddate": Date()])])
        }
        
        var source = Source(value: ["sourceName" : "hoge",
                                    "createdDate" : Date()])
        if(addSourceSwitch){
            //出典に単語帳名を追加する場合
            
            //追加する出典（単語帳名）
            let wnbn = singleton.getWordNoteBook().wordNoteBookName
            source = Source(value: ["sourceName" : wnbn,
                                    "createdDate": Date()])

            //データベース内に保存してあるSourceを単語帳名で検索し取得
            let results = realm.objects(Source.self).filter("sourceName = %@",wnbn)
            let sourcelist: [Source] = Array(results)
            
            if(sourcelist.isEmpty){
                //初めて来る出典なら出典を新規登録する
                try! realm.write {
                    realm.add(source)
                }
            }else{
                //既にSourceにあった出典なら、取ってきたSourceを追加用の出典にする
                //(ここで新規に作ったSourceでやると追加時にキー重複エラーになる)
                source = results.first!
            }
        }
        
        for i in 0..<scrapedWord.getWordData().count{
            
            //一つ分の訳文
            let scrapedWordData:ScrapedWordData = scrapedWord.getWordData()[i]
            
            //品詞データを取得
            let pos = self.getPartOfSpeechData(posname: scrapedWordData.getPartOfSpeech())
            
            try! realm.write {
                //新規単語データを登録
                let newworddata = WordData(value: ["word": newword,
                                                   "partofspeech": pos,
                                                   "meanidx": i+1,
                                                   "mean": scrapedWordData.getMean(),
                                                    "example_q": scrapedWordData.getExEn(),
                                                    "example_a": scrapedWordData.getExJa()])
                
                realm.add(newworddata)

                if(addSourceSwitch){
                    //「出典に単語帳名を追加する」スイッチがON → 出典を追加
                    newworddata.source.append(source)
                }
            }
        }
    }
    
    //既に同じ英単語が辞書に登録されているかチェック
    func checkRegisteredWordinDictionary(wordname: String) -> Bool{
        //Realm
        let realm = try! Realm()
        let results = realm.objects(Word.self).filter("wordName = %@",wordname)
        if results.count > 0 {
            return true
        }else{
            return false
        }
    }

    //既に同じ英単語が単語帳に登録されているかチェック
    func checkRegisteredWordinWordNote(wordname: String) -> Bool{
        //Realm
        let realm = try! Realm()
        let results = realm.objects(WordNote.self).filter("wordnotebook.wordNoteBookName = %@",singleton.getWordNoteBook().wordNoteBookName).filter("word.wordName = %@",wordname)
        if results.count > 0 {
            return true
        }else{
            return false
        }
    }

    //品詞名から品詞データを取得。無い場合は新しく追加する
    func getPartOfSpeechData(posname: String)-> PartsofSpeech{
        //Realm
        let realm = try! Realm()
        //品詞名から品詞を取得
        let results = realm.objects(PartsofSpeech.self).filter("partsOfSpeechName = %@",posname)
        if results.count > 0 {
            return results.first!
        }else{
            //品詞がRealmにない場合は登録
            var maxId: Int? = realm.objects(PartsofSpeech.self).value(forKeyPath: "@max.partsOfSpeechId") as? Int
            
            if(maxId == nil){
                maxId = -1;
            }
            
            let newpos = PartsofSpeech(value: ["partsOfSpeechId": maxId! + 1,
                                          "partsOfSpeechName": posname,
                                          "createdDate": Date()])
            try! realm.write {
                realm.add(newpos)
            }
            return newpos
        }
    }
}
