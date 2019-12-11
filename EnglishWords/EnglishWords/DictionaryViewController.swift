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
    
    //登録語数
    @IBOutlet var wordNum: UILabel!
        
    var wordlist: [Word] = []
    
    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance

    //セルの高さ
    let cellHeight: CGFloat = 60
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    let smallalphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    var alphabetlocked: [Bool] = []
    var alphabetIndex: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データベース内に保存してあるWordを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(Word.self).sorted(byKeyPath: "wordName", ascending: true)
        wordlist = Array(results)
        
        for i in 0..<smallalphabet.count {
            let resultsOfi = results.filter("wordName BEGINSWITH %@", smallalphabet[i]).sorted(byKeyPath: "wordName", ascending: true)
            if resultsOfi.count > 0 {
                alphabetlocked.append(true)
                
                let firstWord = resultsOfi.first
                let index = wordlist.index(of: firstWord!)
                alphabetIndex.append(index!)
            }else{
                alphabetlocked.append(false)
                alphabetIndex.append(0)
            }
        }
        
        //sidetableのラベルを折り返す設定
        sidetable.estimatedRowHeight=120
        sidetable.rowHeight=UITableViewAutomaticDimension
        
        //登録語数ラベルに登録語数を設定する
        wordNum.text =  wordlist.count.description + "語"
        wordNum.textColor = UIColor.white                   //字は白
        wordNum.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)  //ラベルの背景色
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            if(singleton.getAddWordFromDictionary()){
                singleton.saveAddWordFromDictionary(awfd: false)
                performSegue(withIdentifier: singleton.getStringValue(key: "Segue.dictionary.configureWordNoteBook"),sender: nil)
            }else{
                performSegue(withIdentifier: singleton.getStringValue(key: "Segue.dictionary.top"),sender: nil)
            }
        }else if(sender.tag == 1){
            performSegue(withIdentifier: singleton.getStringValue(key: "Segue.dictionary.searchWord"),sender: nil)
        }
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
            if(word.wordName.contains(" ")){
                cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
            }else{
                cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            }
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
                cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            }else{
                //セルを選択不可
                cell.selectionStyle = .none
                //ラベルの文字は黒、セルの背景はグレーにする
                label.textColor = UIColor.black
                cell.backgroundColor = UIColor.lightGray
            }
            
            return cell
        }
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if table.tag == 0 {
            if(singleton.getAddWordFromDictionary()){
                //単語帳設定画面から遷移して単語を選択した時の動作
                //選択したセルの単語を記録
                let selectedWord = wordlist[indexPath.row]
                //Realm、既に同じ単語が登録されてないか確認
                let realm = try! Realm()
                let results = realm.objects(WordNote.self).filter("wordnotebook == %@ && word.wordName == %@",singleton.getWordNoteBook(),selectedWord.wordName)
                if results.count > 0 {
                    //既に同じ英単語が辞書に登録されているためエラー出させる
                    aa.showErrorAlert(vc: self, m: "既に同じ英単語が辞書にあります")
                }else{
                    let cardresults = realm.objects(WordNote.self).filter("wordnotebook == %@",singleton.getWordNoteBook())
                    var maxId: Int = -1
                    if cardresults.count == 0 {
                        maxId = 0
                    }else{
                        maxId = cardresults.value(forKeyPath: "@max.wordidx")! as! Int
                    }

                    try! realm.write {
                        realm.add([WordNote(value: ["wordnotebook": singleton.getWordNoteBook(),
                                                    "word": selectedWord,
                                                    "wordidx": (maxId + 1),
                                                    "registereddate": Date()])])
                    }
                    performSegue(withIdentifier: singleton.getStringValue(key: "Segue.dictionary.configureWordNoteBook"),sender: nil)
                }
            }else{
                //選択したセルの単語を記録
                singleton.saveWord(w: wordlist[indexPath.row])
                // ConfigureWordViewController へ遷移するために Segue を呼び出す
                performSegue(withIdentifier: singleton.getStringValue(key: "Segue.dictionary.configureWord"), sender: nil)
            }
        }else{
            //テーブルを指定したアルファベットの単語までスクロール
            scrolltoTopofSelectedAlphabetCell(wordIndex: indexPath.row)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == singleton.getStringValue(key: "Segue.dictionary.configureWord")) {
            let _: ConfigureWordViewController = (segue.destination as? ConfigureWordViewController)!
            //現選択単語帳リセット（単語設定->辞書に戻るために設定）
            singleton.saveWordNoteBook(wnb: WordNoteBook())
            singleton.saveWordNote(wn: WordNote())
        }else if (segue.identifier == singleton.getStringValue(key: "Segue.dictionary.configureWordNoteBook")) {
            let _: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            //フラグリセットして単語帳設定画面へ戻る
            singleton.saveAddWordFromDictionary(awfd: false)
        }else if (segue.identifier == singleton.getStringValue(key: "Segue.dictionary.top")) {
            let _: ViewController = (segue.destination as? ViewController)!
            //トップ画面に戻る->singleton全要素リセット
            singleton.allReset()
        }else if (segue.identifier == singleton.getStringValue(key: "Segue.dictionary.searchWord")) {
            let _: SearchWordViewController = (segue.destination as? SearchWordViewController)!
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
                realm.delete(realm.objects(WordNote.self).filter("word.wordName == %@",selectedWord.wordName))
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
            return cellHeight*2
        }else{
            return cellHeight
        }
    }
    
    func scrolltoTopofSelectedAlphabetCell(wordIndex: Int){
        //サイドバーで選択したアルファベットから始まる単語がテーブルの一番上にスクロールされるようにする
        let rowheight: CGFloat = cellHeight
        let offset = CGPoint(x:0,y:rowheight*CGFloat(alphabetIndex[wordIndex]))
        table.setContentOffset(offset, animated: true)
    }
}
