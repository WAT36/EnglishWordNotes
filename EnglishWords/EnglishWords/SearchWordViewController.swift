//
//  SearchWordViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/05/08.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class SearchWordViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet var wordNameTextField: UITextField!
    @IBOutlet var levelTextField: UITextField!
    @IBOutlet var meanTextField: UITextField!

    let aa = AlertAction()
    let singleton :Singleton = Singleton.sharedInstance

    //検索条件のリスト
    var querylist: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //キーボード外タップしたらキーボード閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 0){
            performSegue(withIdentifier: singleton.getStringValue(key: "Segue.searchWord.dictionary"),sender: nil)
        }else if(sender.tag == 1){
            if((wordNameTextField.text?.isEmpty)! && (meanTextField.text?.isEmpty)!){
                aa.showErrorAlert(vc: self, m: "検索条件として単語名または訳文を入力してください")
            }else if(!canSearchWord(levelTextField.text!)){
                aa.showErrorAlert(vc: self, m: "レベルには半角数字を入力してください")
            }else{
                //単語の検索条件作成
                makeQuery(textfield: wordNameTextField,attribute: "word.wordName")
                //訳文の検索条件作成
                makeQuery(textfield: meanTextField,attribute: "mean")
                //レベルの検索条件作成
                makeLevelQuery(textfield: levelTextField,attribute: "word.level")
                performSegue(withIdentifier: singleton.getStringValue(key: "Segue.searchWord.searchResult"),sender: nil)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == singleton.getStringValue(key: "Segue.searchWord.dictionary")) {
            let _: DictionaryViewController = (segue.destination as? DictionaryViewController)!
        }else if(segue.identifier == singleton.getStringValue(key: "Segue.searchWord.searchResult")){
            let srVC: SearchResultViewController = (segue.destination as? SearchResultViewController)!
            srVC.querylist = querylist
        }
    }
    
    //指定された条件をもとにRealmへの検索条件を作成するメソッド
    func makeQuery(textfield: UITextField,attribute: String){
        //単語名検索の欄に何か入力されている場合、それに則り検索条件を作る
        if(!(textfield.text?.isEmpty)!){
            var wordquery = attribute + " "
            wordquery.append("LIKE '")
            wordquery.append(textfield.text!)
            wordquery.append("'")
            querylist.append(wordquery)
        }
    }
    
    //指定されたレベルの条件をもとにRealmへの検索条件を作成するメソッド
    func makeLevelQuery(textfield: UITextField,attribute: String){
        //レベル検索の欄に何か入力されている場合、それに則り検索条件を作る
        if(!(textfield.text?.isEmpty)!){
            let query = attribute + " = " + textfield.text!
            querylist.append(query)
        }
    }
    
    // 単語検索が行えるかを判定（レベルが空欄または半角かつ数字のみか）
    func canSearchWord(_ str: String) -> Bool{
        return str.isEmpty || (isNumber(str) && str.isAlphanumeric())
    }
    
    // 文字列が数値に変換可能かを調べる。
    func isNumber(_ str:String) -> Bool {
        //文字列が数値のみで出来ているか
        let predicate = NSPredicate(format: "SELF MATCHES '\\\\d+'")
        //文字列が半角文字になっているかも合わせて変換可能かを判定する
        return predicate.evaluate(with: str) && str.isAlphanumeric()
    }
}
