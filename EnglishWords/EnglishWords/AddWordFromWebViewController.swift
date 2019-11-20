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
    let infoList = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Constant", ofType: "plist")!)

    var inputword: String = ""
    var poslist: [String] = []
    var meanlist: [String] = []
    var exEnlist: [String] = []
    var exJalist: [String] = []
    var addSourceSwitch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordtextField.placeholder = "単語を入力してください"
        
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
        if(exEnlist[indexPath.row].isEmpty){
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
            poslist.remove(at: indexPath.row)
            meanlist.remove(at: indexPath.row)
            exEnlist.remove(at: indexPath.row)
            exJalist.remove(at: indexPath.row)
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
            performSegue(withIdentifier: infoList!.value(forKeyPath: "addWordFromWeb.configureWordNoteBook") as! String,sender: nil)
        }else if(sender.tag == 1){
            if poslist.isEmpty || meanlist.isEmpty {
                aa.showErrorAlert(vc: self, m: "登録する訳文がありません")
            }else if (wordtextField.text?.isEmpty)! || inputword.isEmpty {
                aa.showErrorAlert(vc: self, m: "単語が入力されていません")
            }else if (self.checkRegisteredWordinWordNote(wordname: inputword)){
                aa.showErrorAlert(vc: self, m: "既に同じ英単語が単語帳に登録されています")
            }else if(self.checkRegisteredWordinDictionary(wordname: inputword)){
                self.addWordalreadyinDictionary()
                performSegue(withIdentifier: infoList!.value(forKeyPath: "addWordFromWeb.configureWordNoteBook") as! String,sender: nil)
            }else{
                self.addScrapedWord()
                performSegue(withIdentifier: infoList!.value(forKeyPath: "addWordFromWeb.configureWordNoteBook") as! String,sender: nil)
            }
        }else if(sender.tag == 2){
            if wordtextField.text!.isEmpty {
                aa.showErrorAlert(vc: self, m: "単語が入力されていません")
            }else{
                inputword = wordtextField.text!
                inputwordname.text = wordtextField.text!
                self.scrapeWebsite(wordName: wordtextField.text!)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == infoList!.value(forKeyPath: "addWordFromWeb.configureWordNoteBook") as? String) {
            let _: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
        } else if (segue.identifier == infoList!.value(forKeyPath: "addWordFromWeb.configureWordNoteBook") as? String) {
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
            aa.showErrorAlert(vc: self, m: "入力された単語は辞書に無いか、複数登録されています")
        }
    }
    
    //スクレイピングした単語を登録する
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
        var pos = self.getPartOfSpeechData(posname: poslist[0])
        
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
        
        for i in 0..<meanlist.count{
            //品詞データを取得
            if i>0 && poslist[i-1] != poslist[i] {
                pos = self.getPartOfSpeechData(posname: poslist[i])
            }
            try! realm.write {
                //新規単語データを登録
                let newworddata = WordData(value: ["word": newword,
                                                   "partofspeech": pos,
                                                   "meanidx": i+1,
                                                   "mean": meanlist[i],
                                                    "example_q": exEnlist[i],
                                                    "example_a": exJalist[i]])
                
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
    
    func scrapeWebsite(wordName: String) {
        //入力されたテキストをtrim、また文中にスペース(=熟語)があったらそれを"+"にする
        var inputWord = wordName.trimmingCharacters(in: .whitespaces)
        inputWord = inputWord.replacingOccurrences(of: " ", with: "+")
        
        if(self.checkRegisteredWordinDictionary(wordname: wordName)){
            addWordAlert.textColor = UIColor.black
        }else{
            addWordAlert.textColor = UIColor.white
        }
        
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
                self.exEnlist.removeAll()
                self.exJalist.removeAll()
                self.aa.showErrorAlert(vc: self, m: "HTTPエラー")
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
            
            let means = doc.xpath("//div[@class='mainBlock hlt_KENEJ']/div[@class='kijiWrp']/div[@class='kiji']/div[@class='Kejje']//div[@class='level0' or @class='KejjeYrHd']")
            
            //品詞・意味リストを全削除
            poslist.removeAll()
            meanlist.removeAll()
            exEnlist.removeAll()
            exJalist.removeAll()
            
            var mean: String = ""
            var nh: String = ""
            var ah: String = ""
            var b: String = ""
            var exEn: String = ""
            var exJa: String = ""
            
            var meannum = -1;
            var knenjsubflag = 0 // 品詞が来た時のフラグ。この次のlevel0は必ず意味として受け取る
            for m in means{
            
                //品詞のタグがある場合は品詞を入れて次に進む
                if(m.css("div[class='KnenjSub']").count > 0){
                    let submean = m.css("span[class='KejjeSm']").first?.text!
                    mean = (m.css("div[class='KnenjSub']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    if( submean != nil ){
                        mean = mean.replacingOccurrences(of: submean!, with: "")
                        mean = mean + "(" + (submean?.trimmingCharacters(in: .whitespaces))! + ")"
                    }
                    knenjsubflag = 2
                    continue
                }else{
                    knenjsubflag -= 1
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
                    meannum = meannum + 1
                    poslist.append("")
                    meanlist.append("")
                    exEnlist.append("")
                    exJalist.append("")
                }else if(knenjsubflag > 0){
                    b = (m.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    meannum = meannum + 1
                    poslist.append("")
                    meanlist.append("")
                    exEnlist.append("")
                    exJalist.append("")
                }else if((m.css("span[class='KejjeYrEn']").count > 0) && (m.css("span[class='KejjeYrJp']").count > 0)){
                    //例文(英日)のタグがある場合は例文を入れる
                    exEn = (m.css("span[class='KejjeYrEn']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    exJa = (m.css("span[class='KejjeYrJp']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }

                //品詞：大節：小節：意味：英例文：日例文
                print(mean + ":" + nh + ":" + ah + ":" + b + ":" + exEn + ":" + exJa + ":" + meannum.description)
                if(!b.isEmpty){
                    poslist[meannum] = mean
                    meanlist[meannum] = b
                    b = ""
                }
                
                if(!exEn.isEmpty){
                    exEnlist[meannum] = exEn
                    exJalist[meannum] = exJa
                    exEn = ""
                    exJa = ""
                }
            }
            
            if( poslist.isEmpty || meanlist.isEmpty ){
                aa.showErrorAlert(vc: self, m: "入力された単語では訳文が検出されませんでした")
            }
        }
    }
}
