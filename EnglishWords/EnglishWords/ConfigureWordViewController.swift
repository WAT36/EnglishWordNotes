//
//  ConfigureWordViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/02/03.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ConfigureWordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var wordnamelabel: UILabel!
    @IBOutlet var table:UITableView!
    
    var wordnotebook: WordNoteBook?
    var worddatalist: [WordData] = []
    var wordnote: WordNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wordname = wordnote?.worddata?.word?.wordName
        wordnamelabel.text = wordname
        
        //選択したWordDataからデータベース内に保存してあるWordDataを全て取得
        let realm: Realm = try! Realm()
        let results = realm.objects(WordData.self).filter("word.wordName == %@",wordname!)
        worddatalist = Array(results)
        
        //tableのラベルを折り返す設定
        table.estimatedRowHeight=120
        table.rowHeight=UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return worddatalist.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                                 for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        let oneworddata = worddatalist[indexPath.row]
        let partofspeech = cell.viewWithTag(1) as! UILabel
        partofspeech.numberOfLines = 0
        partofspeech.text = oneworddata.partofspeech?.partsOfSpeechName
        let mean = cell.viewWithTag(2) as! UILabel
        mean.numberOfLines = 0
        mean.text = oneworddata.mean
        
        return cell
    }
    
    @IBAction func buttonTapped(sender : AnyObject) {
        performSegue(withIdentifier: "returnConfigureWordViewController",sender: nil)
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnConfigureWordViewController") {
            let configureWordNoteVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            configureWordNoteVC.wordnotebook = wordnotebook
        }
    }
    
    // sideTableのCell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
