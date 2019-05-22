//
//  TestOfWordNoteBookViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/18.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class TestOfWordNoteBookViewController: UIViewController {
    
    @IBOutlet var nowWord: UILabel!
    @IBOutlet var nowWordNote: UILabel!
    @IBOutlet var count: UILabel!
    
    @IBOutlet var table:UITableView!

    var wordnotebook: WordNoteBook?
    
    //検索条件のリスト
    var queryList: [String] = []
    
    //検索結果の単語リスト
    var wordNoteList: [WordNote] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース内に保存してあるWordnoteを取得し、検索条件のリストで絞る
        let realm: Realm = try! Realm()
        var results = realm.objects(WordNote.self).filter("wordnotebook.wordNoteBookId = %@",wordnotebook?.wordNoteBookId)
            .sorted(byKeyPath: "wordidx", ascending: true)
        for i in 0..<queryList.count {
            results = results.filter(queryList[i])
        }
        wordNoteList = Array(results)
        if(wordNoteList.count == 0){
            //検索結果無し、エラーアラート出して戻させる
            showAlert(mes: "検索結果がありません")
        }else{
            nowWord.text = wordNoteList[0].word?.wordName
            nowWordNote.text = wordnotebook?.wordNoteBookName
            count.text = "1/" + wordNoteList.count.description
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returntoConfigureTestOfWordNoteBookViewController",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returntoConfigureTestOfWordNoteBookViewController") {
            let ctwnbVC: ConfigureTestOfWordNoteBookViewController = (segue.destination as? ConfigureTestOfWordNoteBookViewController)!
            ctwnbVC.wordnotebook = wordnotebook
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
