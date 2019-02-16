//
//  DictionaryViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/29.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DictionaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table:UITableView!
    @IBOutlet var sidetable:UITableView!
    
    var wordlist: [Word] = []
    var selectedWord: Word?
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    let smallalphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    var alphabetlocked: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データベース内に保存してあるWordNoteBookを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(Word.self).sorted(byKeyPath: "wordName", ascending: true)
        wordlist = Array(results)
        
        for i in 0..<smallalphabet.count {
            if results.filter("wordName BEGINSWITH %@", smallalphabet[i]).count > 0 {
                alphabetlocked.append(true)
            }else{
                alphabetlocked.append(false)
            }
        }
        
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
            return wordlist.count
        }else{
            return alphabet.count
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
            let word = wordlist[indexPath.row]
            let label = cell.viewWithTag(1) as! UILabel
            label.numberOfLines = 0
            label.text = word.wordName
            
            return cell
        }else{
            // tableCell の ID で UITableViewCell のインスタンスを生成
            let cell = table.dequeueReusableCell(withIdentifier: "sidetablecell",
                                                 for: indexPath)
            // Tag番号  で UILabel インスタンスの生成
            let label = cell.viewWithTag(1) as! UILabel
            label.numberOfLines = 0
            label.text = alphabet[indexPath.row]
            
            if(alphabetlocked[indexPath.row]){
                //セルを選択可
                cell.selectionStyle = .default
                //ラベルの文字は黒
                label.textColor = UIColor.black
            }else{
                //セルを選択不可
                cell.selectionStyle = .none
                //ラベルの文字はグレーにする
                label.textColor = UIColor.lightGray
            }
            
            return cell
        }
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if table.tag == 0 {
            //選択したセルの単語帳を記録
            selectedWord = wordlist[indexPath.row]
            // ConfigureWordViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "fromDictionarytoConfigureWord", sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "fromDictionarytoConfigureWord") {
            let cwVC: ConfigureWordViewController = (segue.destination as? ConfigureWordViewController)!
            cwVC.selectedword = selectedWord
        }
    }
    
    //指定したテーブル、セル毎にスワイプを有効、無効にする
    func tableView(_ table: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if table.tag == 0 {
            return true
        }else{
            return false
        }
    }
    
    //選択したセルでスワイプすると削除される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //選択したセルの単語帳を記録
            let selectedWord = wordlist[indexPath.row]
            
            wordlist.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //Realmデータベースからも削除
            let realm = try! Realm()
            
            try! realm.write {
                //単語帳データから削除
                realm.delete(realm.objects(WordNote.self).filter("worddata.word.wordName == %@",selectedWord.wordName))
                //単語データから削除
                realm.delete(realm.objects(WordData.self).filter("word.wordName == %@",selectedWord.wordName))
                //単語マスタから削除
                realm.delete(selectedWord)
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
