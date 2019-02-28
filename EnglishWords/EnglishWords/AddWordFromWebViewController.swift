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

class AddWordFromWebViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var wordtextField: UITextField!
    
    @IBOutlet var level: UILabel!
    
    var wordnotebook: WordNoteBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordtextField.placeholder = "単語を入力してください"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                self.parseHTML(html: html)
            }
        }
    }
    
    func parseHTML(html: String) {
        if let doc = try? HTML(html: html, encoding: .utf8) {
            print(doc.title)
            print("レベル：")
            level.text = doc.css("span[class='learning-level-content']")[0].text

            let kenej = doc.css("div[class='mainBlock hit_KENEJ']")
            
            for link in doc.css("div[class='KnenjSub']") {
                print(link.content)
                print(link.className)
                print(link.innerHTML)
                print(link.tagName)
                print(link.text)
                print(link.toHTML)
                print(link.toXML)
                print("----------")
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
