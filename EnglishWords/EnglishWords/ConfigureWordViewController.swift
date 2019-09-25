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
    @IBOutlet var pronounce: UILabel!
    @IBOutlet var level: UILabel!
    @IBOutlet var table:UITableView!
    
    var worddatalist: [WordData] = []
    var wordnote: WordNote?
    var selectedword: Word?
    var selectedmean: WordData?
    var toremovemean: WordData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(wordnote != nil){
            selectedword = wordnote?.word
        }
        
        wordnamelabel.text = selectedword?.wordName
        pronounce.text = selectedword?.pronounce
        level.text = selectedword?.level.description
            
        //選択したWordからデータベース内に保存してあるWordDataを全て取得、meanidxでソート
        let realm: Realm = try! Realm()
        let results = realm.objects(WordData.self).filter("word.wordName == %@",selectedword?.wordName).sorted(byKeyPath: "meanidx")
        worddatalist = Array(results)
        
        //tableのラベルを折り返す設定
        table.estimatedRowHeight=120
        table.rowHeight=UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return worddatalist.count + 1
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                                 for: indexPath)
        if indexPath.row < worddatalist.count {
            // Tag番号  で UILabel インスタンスの生成
            let oneworddata = worddatalist[indexPath.row]
            let partofspeech = cell.viewWithTag(1) as! UILabel
            partofspeech.numberOfLines = 0
            partofspeech.text = oneworddata.partofspeech?.partsOfSpeechName
            let mean = cell.viewWithTag(2) as! UILabel
            mean.numberOfLines = 0
            mean.text = oneworddata.mean
            if(oneworddata.example_q.isEmpty){
                cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            }else{
                cell.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 0.5)
            }
        } else {
            let blank = cell.viewWithTag(1) as! UILabel
            blank.numberOfLines = 0
            blank.text = ""
            
            let mean = cell.viewWithTag(2) as! UILabel
            mean.numberOfLines = 0
            mean.text = "➕訳文を追加する"
            cell.backgroundColor = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 0.5)
        }
        
        return cell
    }
    
    @IBAction func ButtonTouchDown(_ sender: Any) {
        if(wordnote != nil){
            performSegue(withIdentifier: "returnToConfigureWordNote",sender: nil)
        }else if(selectedword != nil){
            performSegue(withIdentifier: "returnToDictionary",sender: nil)
        }
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < worddatalist.count {
            //選択したセルの単語を記録
            selectedmean = worddatalist[indexPath.row]
        }else{
            //単語名だけを入れたもの
            selectedmean = WordData(value: ["word": selectedword])
        }
        // ConfigureWordViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "toConfigureMeanViewController", sender: nil)

    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnToConfigureWordNote") {
            let configureWordNoteVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            configureWordNoteVC.wordnotebook = wordnote?.wordnotebook
        }else if (segue.identifier == "returnToDictionary"){
            let _: DictionaryViewController = (segue.destination as? DictionaryViewController)!
        }else if (segue.identifier == "toConfigureMeanViewController"){
            let configureMeanVC: ConfigureMeanViewController = (segue.destination as? ConfigureMeanViewController)!
            configureMeanVC.mean = selectedmean
            if wordnote != nil {
                configureMeanVC.wordnote = wordnote
            }
            
            if selectedmean?.partofspeech != nil {
                configureMeanVC.newMeanFlag = false
            }else{
                configureMeanVC.newMeanFlag = true
            }
        }
    }
    
    //指定したテーブル、セル毎にスワイプを有効、無効にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < worddatalist.count {
            return true
        }else{
            return false
        }
    }
    
    //選択したセルでスワイプすると削除される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //選択したセルの単語帳を記録
            toremovemean = worddatalist[indexPath.row]
            
            worddatalist.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //Realmデータベースからも削除
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(toremovemean!)
            }
            
            toremovemean = nil
        }
    }
    
    // sideTableのCell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
