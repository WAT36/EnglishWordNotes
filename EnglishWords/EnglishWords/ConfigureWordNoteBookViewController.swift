//
//  ConfigureWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/23.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class ConfigureWordNoteBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table:UITableView!
    @IBOutlet var sidetable:UITableView!
    @IBOutlet var wordNote: UILabel!
    @IBOutlet var wordNum: UILabel!

    var wordlist: [WordNote] = []
    var card: WordNote?
    var wordnotebook: WordNoteBook?
    
    let sidebarlist = ["単語追加","確認テスト","エクスポート","オプション(未実装)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース内に保存してあるWordNoteを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(WordNote.self).filter("wordnotebook.wordNoteBookId == %@",wordnotebook?.wordNoteBookId).sorted(byKeyPath: "wordidx", ascending: true)
        wordlist = Array(results)

        //単語帳名ラベルに単語帳名を設定する
        wordNote.text = wordnotebook?.wordNoteBookName
        //登録語数ラベルに登録語数を設定する
        wordNum.text =  wordlist.count.description + "語"

        //sidetableのラベルを折り返す設定
        sidetable.estimatedRowHeight=120
        sidetable.rowHeight=UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if table.tag == 1 {
            return sidebarlist.count
        }else{
            return wordlist.count
        }
    }
    
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if table.tag == 1 {
            // tableCell の ID で UITableViewCell のインスタンスを生成
            let cell = table.dequeueReusableCell(withIdentifier: "sidetablecell",
                                                 for: indexPath)
            // Tag番号  で UILabel インスタンスの生成
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.numberOfLines = 0
            label1.text = sidebarlist[indexPath.row]
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
            
            return cell
        }else{
            // tableCell の ID で UITableViewCell のインスタンスを生成
            let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                                 for: indexPath)
            // Tag番号  で UILabel インスタンスの生成
            let oneword = wordlist[indexPath.row]
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.numberOfLines = 0
            label1.text = oneword.word?.wordName
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            
            return cell
        }
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if table.tag == 1 {
            if sidebarlist[indexPath.row] == "単語追加" {
                // AddWordViewController へ遷移するために Segue を呼び出す
                addWordDispAlert(sender: table)
            }else if sidebarlist[indexPath.row] == "エクスポート" {
                // AddWordViewController へ遷移するために Segue を呼び出す
                exportDispAlert(sender: table)
            }else if sidebarlist[indexPath.row] == "確認テスト"{
                // ConfigureTestOfWordNoteBookViewController へ遷移するために Segue を呼び出す
                performSegue(withIdentifier: "toConfigureTestFromConfigureWordNoteViewController", sender: nil)
            }
        }else{
            //選択したセルの単語を記録
            card = wordlist[indexPath.row]
            // ConfigureWordViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toConfigureWordViewController", sender: nil)
            
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toAddWordViewController") {
            let addWordVC: AddWordViewController = (segue.destination as? AddWordViewController)!
            addWordVC.wordnotebook = wordnotebook
        }else if (segue.identifier == "toDictionaryViewController"){
            let addDVC: DictionaryViewController = (segue.destination as? DictionaryViewController)!
            addDVC.addWordFlag = true
            addDVC.wnb = wordnotebook
        }else if (segue.identifier == "toConfigureWordViewController"){
            let configWordVC: ConfigureWordViewController = (segue.destination as? ConfigureWordViewController)!
            configWordVC.wordnote = card
        }else if (segue.identifier == "toAddWordFromWebViewController"){
            let awfwVC: AddWordFromWebViewController = (segue.destination as? AddWordFromWebViewController)!
            awfwVC.wordnotebook = wordnotebook
        }else if(segue.identifier == "toConfigureTestFromConfigureWordNoteViewController"){
            let ctwnbVC: ConfigureTestOfWordNoteBookViewController = (segue.destination as? ConfigureTestOfWordNoteBookViewController)!
            ctwnbVC.wordnotebook = wordnotebook
        }
    }
    
    //指定したテーブル、セル毎にスワイプを有効、無効にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0 {
            return true
        }else{
            return false
        }
    }
    
    //選択したセルでスワイプすると削除される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //選択したセルの単語帳を記録
            card = wordlist[indexPath.row]
            
            wordlist.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //Realmデータベースからも削除
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(card!)
            }
        }
    }
    
    // sideTableのCell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if table.tag == 1 {
            return 120.0
        }else{
            return 60.0
        }
    }
    
    // 単語追加ボタン（セル）を押下した時にアラートを表示するメソッド
    @IBAction func addWordDispAlert(sender: UITableView) {
        
        //アラートの設定
        let alert: UIAlertController = UIAlertController(title: "単語追加", message: "どの方法で英単語を追加しますか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        //アラート①：既存の英単語から追加する
        let addWordFromDictionaryAction: UIAlertAction = UIAlertAction(title: "既存の英単語から追加する", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toDictionaryViewController", sender: nil)
        })
        
        //アラート②：新規の英単語を追加する
        let addNewWordAction: UIAlertAction = UIAlertAction(title: "新規に英単語を追加する(手動)", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toAddWordViewController", sender: nil)
        })
        
        //アラート③：新規の英単語を(Webから)追加する
        let addNewWordFromWebAction: UIAlertAction = UIAlertAction(title: "新規に英単語を追加する(Web)", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "toAddWordFromWebViewController", sender: nil)
        })
        
        //アラート③：キャンセル
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        
        //UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(addWordFromDictionaryAction)
        alert.addAction(addNewWordAction)
        alert.addAction(addNewWordFromWebAction)

        //アラートを表示
        present(alert, animated: true, completion: nil)
    }
    
    // エクスポートボタン（セル）を押下した時にアラートを表示するメソッド
    @IBAction func exportDispAlert(sender: UITableView) {
        
        //アラートの設定
        let alert: UIAlertController = UIAlertController(title: "ファイル名指定", message: "エクスポートするファイル名を記入してください", preferredStyle:  UIAlertControllerStyle.alert)
        
        //ファイル名入力用textFieldの追加
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.tag  = 1
        })

        //ボタン①：入力したファイル名でRealmをエクスポートする
        let okAction: UIAlertAction = UIAlertAction(title: "決定", style: UIAlertActionStyle.default, handler:{[weak alert] (action) -> Void in
            // ボタンが押された時の処理を書く（クロージャ実装）
            guard let textFields = alert?.textFields else {
                return
            }
            
            guard !textFields.isEmpty else {
                return
            }
            
            var filename: String = ""
            for text in textFields {
                filename = text.text!
            }
            
            if(filename.isEmpty){
                //エラー出させる
            }else{
                self.exportRealmFile(filename: filename)
            }
        })
        
        //ボタン②：キャンセル
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        
        //UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        //アラートを表示
        present(alert, animated: true, completion: nil)
    }
    
    func exportRealmFile(filename: String){
        
        let realm = try! Realm()
        do {
            //ファイル名
            let fileURL = realm.configuration.fileURL!.deletingLastPathComponent().appendingPathComponent(filename)
            try realm.writeCopy(toFile: fileURL)
            print(fileURL.path)
            print("Realm export Succeeded.")
        }catch {
            //エラー処理
            print("Error. Realm Export Failed.")
        }
    }
}
