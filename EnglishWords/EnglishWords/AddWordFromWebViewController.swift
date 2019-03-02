//
//  AddWordFromWebViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/02/26.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Alamofire
import Kanna

class AddWordFromWebViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var table:UITableView!
    @IBOutlet var wordtextField: UITextField!
    
    @IBOutlet var level: UILabel!
    @IBOutlet var pronounce: UILabel!
    
    var poslist: [String] = []
    var meanlist: [String] = []
    
    var wordnotebook: WordNoteBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordtextField.placeholder = "単語を入力してください"
        
        //tableのラベルを折り返す設定
        table.estimatedRowHeight=120
        table.rowHeight=UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //テーブルのセルの数を設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meanlist.count
    }
    
    //テーブルのセルの要素を設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        // Tag番号  で UILabel インスタンスの生成
        let poslabel = cell.viewWithTag(1) as! UILabel
        poslabel.numberOfLines = 0
        poslabel.text = poslist[indexPath.row]
        let meanlabel = cell.viewWithTag(2) as! UILabel
        meanlabel.numberOfLines = 0
        meanlabel.text = meanlist[indexPath.row]
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
        
        return cell
    }
    
    // TableのCell の高さを１２０にする
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    @IBAction func buttonTapped(sender : UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: "returnConfigureWordNoteBookViewContoller",sender: nil)
        }else if(sender.tag == 1){
            performSegue(withIdentifier: "toConfigureWordNoteBookViewContoller",sender: nil)
        }else if(sender.tag == 2){
            if wordtextField.text!.isEmpty {
                self.showAlert()
            }else{
                self.scrapeWebsite(wordName: wordtextField.text!)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnConfigureWordNoteBookViewContoller") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
        } else if (segue.identifier == "toConfigureWordNoteBookViewContoller") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
        }
    }
    
    func scrapeWebsite(wordName: String) {
        
        //GETリクエスト 指定URLのコードを取得
        let fqdn = "https://ejje.weblio.jp/content/" + wordName
        Alamofire.request(fqdn).responseString { response in
            print("\(response.result.isSuccess)")
            
            if let html = response.result.value {
                //入力した単語でスクレイピング開始・テーブル更新
                self.parseHTML(html: html)
                self.table.reloadData()
            }
        }
    }
    
    func parseHTML(html: String) {
        if let doc = try? HTML(html: html, encoding: .utf8) {
            level.text = doc.css("span[class='learning-level-content']").first!.text
            pronounce.text = doc.css("span[class='phoneticEjjeDesc']").first!.text
            
            let means = doc.xpath("//div[@class='mainBlock hlt_KENEJ']/div[@class='kijiWrp']/div[@class='kiji']/div[@class='Kejje']/div[@class='level0']")
            
            //品詞・意味リストを全削除
            poslist.removeAll()
            meanlist.removeAll()
            
            var mean: String = ""
            var nh: String = ""
            var ah: String = ""
            var b: String = ""
            for m in means{
            
                //品詞のタグがある場合は品詞を入れて次に進む
                if(m.css("div[class='KnenjSub']").count > 0){
                    let submean = m.css("span[class='KejjeSm']").first?.text!
                    mean = (m.css("div[class='KnenjSub']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    if( submean != nil ){
                        mean = mean.replacingOccurrences(of: submean!, with: "")
                        mean = mean + "(" + (submean?.trimmingCharacters(in: .whitespaces))! + ")"
                    }
                    continue
                }
                
                //大節のタグがある場合は大節を入れる
                if(m.css("p[class='lvlNH']").count > 0 && !(m.css("p[class='lvlNH']").first?.text?.isEmpty)!){
                    nh = (m.css("p[class='lvlNH']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }
                
                //小節のタグがある場合は小節を入れる
                if(m.css("p[class='lvlAH']").count > 0){
                    ah = (m.css("p[class='lvlAH']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }
                
                //意味のタグがある場合は小節を入れる
                if(m.css("p[class='lvlB']").count > 0){
                    b = (m.css("p[class='lvlB']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                }else{
                    continue
                }
                
                //品詞：大節：小節：意味
                print(mean + ":" + nh + ":" + ah + ":" + b)
                poslist.append(mean)
                meanlist.append(b)
            }
        }
    }
    
    func showAlert() {
        
        // アラートを作成
        let alert = UIAlertController(
            title: "エラー",
            message: "単語が入力されていません",
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
}
