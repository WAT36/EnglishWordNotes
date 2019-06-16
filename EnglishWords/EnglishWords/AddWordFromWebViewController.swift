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
    
    var inputword: String = ""
    var poslist: [String] = []
    var meanlist: [String] = []
    var addSourceSwitch: Bool = false
    
    var wordnotebook: WordNoteBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordtextField.placeholder = "単語を入力してください"
        
        //スイッチは最初OFF
        uiswitch.isOn = false
        
        //tableのラベルを折り返す設定
        table.estimatedRowHeight=120
        table.rowHeight=UITableViewAutomaticDimension
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
        return meanlist.count
    }
    
    //テーブルのセルの要素を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        let poslabel = cell.viewWithTag(1) as! UILabel
        poslabel.numberOfLines = 0
        poslabel.text = poslist[indexPath.row]
        let meanlabel = cell.viewWithTag(2) as! UILabel
        meanlabel.numberOfLines = 0
        meanlabel.text = meanlist[indexPath.row]
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
        
        return cell
    }
    
    // TableのCell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    @IBAction func buttonTapped(sender : UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnConfigureWordNoteBookViewContoller",sender: nil)
        }else if(sender.tag == 1){
            if poslist.isEmpty || meanlist.isEmpty {
                self.showAlert(mes: "登録する訳文がありません")
            }else if (wordtextField.text?.isEmpty)! || inputword.isEmpty {
                self.showAlert(mes: "単語が入力されていません")
            }else if (self.checkRegisteredWord(wordname: inputword)){
                self.showAlert(mes: "既に同じ英単語が登録されています")
            }else{
                self.addScrapedWord()
                performSegue(withIdentifier: "toConfigureWordNoteBookViewContoller",sender: nil)
            }
        }else if(sender.tag == 2){
            if wordtextField.text!.isEmpty {
                self.showAlert(mes: "単語が入力されていません")
            }else{
                inputword = wordtextField.text!
                inputwordname.text = wordtextField.text!
                self.scrapeWebsite(wordName: wordtextField.text!)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnConfigureWordNoteBookViewContoller") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
        } else if (segue.identifier == "toConfigureWordNoteBookViewContoller") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
        }
    }
    
    //スクレイピングした単語を登録する
    func addScrapedWord(){
        
        //Realm
        let realm = try! Realm()
        
        //単語を新規登録する。option1には発音記号、option2にはレベルを書く
        let newword = Word(value: ["wordName": inputword,
                                   "createdDate": Date(),
                                   "option1": pronounce.text!,
                                    "option2": level.text!])
        
        //現単語帳に登録するための登録番号を取得
        var maxId: Int
        let cardresults = realm.objects(WordNote.self).filter("wordnotebook == %@",wordnotebook!)
        if cardresults.count == 0 {
            maxId = 0
        }else{
            maxId = cardresults.value(forKeyPath: "@max.wordidx")! as! Int
        }
        
        try! realm.write {
            realm.add([newword])
            realm.add([WordNote(value: ["wordnotebook": wordnotebook!,
                                        "word": newword,
                                        "wordidx": maxId,
                                        "registereddate": Date()])])
        }
        var pos = self.getPartOfSpeechData(posname: poslist[0])
        
        var source = Source(value: ["sourceName" : "hoge",
                                    "createdDate" : Date()])
        if(addSourceSwitch){
            //出典に単語帳名を追加する場合
            
            //追加する出典（単語帳名）
            let wnbn = wordnotebook?.wordNoteBookName
            source = Source(value: ["sourceName" : wnbn!,
                                    "createdDate": Date()])

            //データベース内に保存してあるSourceを単語帳名で検索し取得
            let results = realm.objects(Source.self).filter("sourceName = %@",wnbn!)
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
        
        for i in 0..<meanlist.count{
            //品詞データを取得
            if i>0 && poslist[i-1] != poslist[i] {
                pos = self.getPartOfSpeechData(posname: poslist[i])
            }
            try! realm.write {
                //新規単語データを登録
                var newworddata = WordData(value: ["word": newword,
                                                   "partofspeech": pos,
                                                   "meanidx": i+1,
                                                   "mean": meanlist[i],
                                                    "example": "例文(未実装)"])
                
                realm.add(newworddata)

                if(addSourceSwitch){
                    //「出典に単語帳名を追加する」スイッチがON → 出典を追加
                    newworddata.source.append(source)
                }
            }
        }
    }
    
    //既に同じ英単語が辞書に登録されているかチェック
    func checkRegisteredWord(wordname: String) -> Bool{
        //Realm
        let realm = try! Realm()
        let results = realm.objects(Word.self).filter("wordName = %@",wordname)
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
    
    func scrapeWebsite(wordName: String) {
        //入力されたテキストをtrim、また文中にスペース(=熟語)があったらそれを"+"にする
        var inputWord = wordName.trimmingCharacters(in: .whitespaces)
        inputWord = inputWord.replacingOccurrences(of: " ", with: "+")
        
        //GETリクエスト 指定URLのコードを取得
        let fqdn = "https://ejje.weblio.jp/content/" + inputWord
        Alamofire.request(fqdn).responseString { response in
            print("\(response.result.isSuccess)")
            
            if !response.result.isSuccess {
                self.wordtextField.text = ""
                self.inputword = ""
                self.inputwordname.text = ""
                self.poslist.removeAll()
                self.meanlist.removeAll()
                self.showAlert(mes: "入力した単語\"" + wordName + "\"での検索結果はありません")
            }
            
            if let html = response.result.value {
                //入力した単語でスクレイピング開始・テーブル更新
                self.parseHTML(html: html)
                self.table.reloadData()
            }
        }
    }
    
    func parseHTML(html: String) {
        if let doc = try? HTML(html: html, encoding: .utf8) {
            var csstemp = doc.css("span[class='learning-level-content']")
            if(csstemp.count != 0){
                level.text = csstemp.first!.text
            }else{
                level.text = ""
            }
            
            csstemp = doc.css("span[class='phoneticEjjeDesc']")
            if(csstemp.count != 0){
                pronounce.text = csstemp.first!.text
            }else{
                pronounce.text = ""
            }
            
            let means = doc.xpath("//div[@class='mainBlock hlt_KENEJ']/div[@class='kijiWrp']/div[@class='kiji']/div[@class='Kejje']/div[@class='level0']")
            
            //品詞・意味リストを全削除
            poslist.removeAll()
            meanlist.removeAll()
            
            var mean: String = ""
            var nh: String = ""
            var ah: String = ""
            var b: String = ""
            for m in means{
            
                //品詞のタグがある場合は品詞を入れて次に進む
                if(m.css("div[class='KnenjSub']").count > 0){
                    let submean = m.css("span[class='KejjeSm']").first?.text!
                    mean = (m.css("div[class='KnenjSub']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    if( submean != nil ){
                        mean = mean.replacingOccurrences(of: submean!, with: "")
                        mean = mean + "(" + (submean?.trimmingCharacters(in: .whitespaces))! + ")"
                    }
                    continue
                }
                
                //大節のタグがある場合は大節を入れる
                if(m.css("p[class='lvlNH']").count > 0 && !(m.css("p[class='lvlNH']").first?.text?.isEmpty)!){
                    nh = (m.css("p[class='lvlNH']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }
                
                //小節のタグがある場合は小節を入れる
                if(m.css("p[class='lvlAH']").count > 0){
                    ah = (m.css("p[class='lvlAH']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }
                
                //意味のタグがある場合は小節を入れる
                if(m.css("p[class='lvlB']").count > 0){
                    b = (m.css("p[class='lvlB']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }else{
                    b = (m.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }
                
                //品詞：大節：小節：意味
                print(mean + ":" + nh + ":" + ah + ":" + b)
                poslist.append(mean)
                meanlist.append(b)
            }
        }
    }
    
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
