//
//  ViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2018/09/16.
//  Copyright © 2018年 T.Wakasugi. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table:UITableView!
    @IBOutlet var sidetable:UITableView!
    
    var booknamelist: [WordNoteBook] = []
    var wordnotebook: WordNoteBook?
    
    let sidebarlist = ["単語帳追加","品詞追加","マスター英単語帳","オプション"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //データベース内に保存してあるWordNoteBookを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(WordNoteBook.self)
        booknamelist = Array(results)
        
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
        
        if table.tag == 0 {
            return booknamelist.count
        }else{
            return sidebarlist.count
        }
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if table.tag == 0 {
            // tableCell の ID で UITableViewCell のインスタンスを生成
            let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                                 for: indexPath)
            // Tag番号  で UILabel インスタンスの生成
            let booknames = booknamelist[indexPath.row]
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.numberOfLines = 0
            label1.text = booknames.wordNoteBookName
            
            return cell
        }else{
            // sidetableCell の ID で UITableViewCell のインスタンスを生成
            let cell = table.dequeueReusableCell(withIdentifier: "sidetablecell",
                                                 for: indexPath)
            // Tag番号  で UILabel インスタンスの生成
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.numberOfLines = 0
            label1.text = sidebarlist[indexPath.row]
            
            return cell
        }
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if table.tag == 0 {
            //選択したセルの単語帳を記録
            wordnotebook = booknamelist[indexPath.row]
            // ConfigureWordNoteBookViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toConfigureWordNoteBookViewController", sender: nil)
        }else{
            if sidebarlist[indexPath.row] == "単語帳追加" {
                // AddWordNoteBookViewController へ遷移するために Segue を呼び出す
                performSegue(withIdentifier: "toSubViewController",sender: nil)
            }else if sidebarlist[indexPath.row] == "品詞追加" {
                // AddPronounceViewController へ遷移するために Segue を呼び出す
                performSegue(withIdentifier: "toAddPartsofSpeechViewController",sender: nil)
            }else if sidebarlist[indexPath.row] == "マスター英単語帳" {
                // DictionaryViewController へ遷移するために Segue を呼び出す
                performSegue(withIdentifier: "toDictionaryViewController",sender: nil)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSubViewController") {
            let _: AddWordNoteBookViewController = (segue.destination as? AddWordNoteBookViewController)!
        }else if (segue.identifier == "toConfigureWordNoteBookViewController"){
            let subVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            //遷移先の画面に選択した単語帳を表示
            subVC.wordnotebook = wordnotebook!
        }else if (segue.identifier == "toAddPartsofSpeechViewController"){
            let _: AddPartsofSpeechViewController = (segue.destination as? AddPartsofSpeechViewController)!
        }else if (segue.identifier == "toDictionaryViewController"){
            let _: DictionaryViewController = (segue.destination as? DictionaryViewController)!
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
            wordnotebook = booknamelist[indexPath.row]
            
            booknamelist.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //Realmデータベースからも削除
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(wordnotebook!)
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
}

