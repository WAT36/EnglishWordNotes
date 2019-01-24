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
    
    var booknamelist: [WordNoteBook] = []
    var wordnotebook: WordNoteBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //データベース内に保存してあるWordNoteBookを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(WordNoteBook.self)
        booknamelist = Array(results)
        booknamelist.append(WordNoteBook(value: ["wordNoteBookId": 999,
                                                 "wordNoteBookName": "単語帳を追加"]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return booknamelist.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        
        // Tag番号  で UILabel インスタンスの生成
        let booknames = booknamelist[indexPath.row]
        let label1 = cell.viewWithTag(1) as! UILabel
        label1.text = booknames.wordNoteBookName

        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        let selectedText = booknamelist[indexPath.row].wordNoteBookName
        if selectedText == "単語帳を追加" {
            // AddWordNoteBookViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toSubViewController",sender: nil)
        }else{
            //選択したセルの単語帳を記録
            wordnotebook = booknamelist[indexPath.row]
            // ConfigureWordNoteBookViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toConfigureWordNoteBookViewController", sender: nil)
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
        }
    }
}

