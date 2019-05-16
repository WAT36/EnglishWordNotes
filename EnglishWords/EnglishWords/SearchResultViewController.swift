//
//  SearchResultViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/12.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //検索条件のリスト
    var querylist: [String] = []
    //検索結果の単語リスト
    var wordlist: [Word] = []
    
    //選択した単語
    var selectedWord: Word?
    
    @IBOutlet var table:UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース内に保存してあるWordを取得し、検索条件のリストで絞る
        let realm: Realm = try! Realm()
        var results = realm.objects(Word.self).sorted(byKeyPath: "wordName", ascending: true)
        
        for i in 0..<querylist.count {
            results = results.filter(querylist[i])
        }
        wordlist = Array(results)
        
        if(wordlist.count == 0){
            //検索結果無し、エラーアラート出して戻させる
            showAlert(mes: "検索結果がありません")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return wordlist.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                                 for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        let word = wordlist[indexPath.row]
        let label = cell.viewWithTag(1) as! UILabel
        label.numberOfLines = 0
        label.text = word.wordName
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
            
        return cell
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnSearchWordViewController",sender: nil)
        }
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        //選択したセルの単語を記録
        selectedWord = wordlist[indexPath.row]
        // ConfigureWordViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "fromSearchResultToConfigureWord", sender: nil)
    }

    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnSearchWordViewController") {
            let _: SearchWordViewController = (segue.destination as? SearchWordViewController)!
        }else if (segue.identifier == "fromSearchResultToConfigureWord") {
            let cwVC: ConfigureWordViewController = (segue.destination as? ConfigureWordViewController)!
            cwVC.selectedword = selectedWord
        }
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
