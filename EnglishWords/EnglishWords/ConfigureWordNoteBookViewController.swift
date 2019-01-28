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
    
    var wordlist: [WordNote] = []
    var card: WordNote?
    var wordnotebook: WordNoteBook?
    
    let sidebarlist = ["単語追加","確認テスト","オプション"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース内に保存してあるWordNoteを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(WordNote.self).filter("wordnotebook.wordNoteBookId == %@",wordnotebook?.wordNoteBookId).sorted(byKeyPath: "wordidx", ascending: true)
        wordlist = Array(results)

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
            
            return cell
        }else{
            // tableCell の ID で UITableViewCell のインスタンスを生成
            let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                                 for: indexPath)
            // Tag番号  で UILabel インスタンスの生成
            let oneword = wordlist[indexPath.row]
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.numberOfLines = 0
            label1.text = oneword.worddata?.word?.wordName
            
            return cell
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
}
