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
    @IBOutlet var wordSearchCondSegmentedControl: UISegmentedControl!
    @IBOutlet var levelTextField: UITextField!
    @IBOutlet var meanTextField: UITextField!
    @IBOutlet var meanSearchCondSegmentedControl: UISegmentedControl!

    //検索条件のリスト
    var querylist: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンを選択中にする場所を指定
        wordSearchCondSegmentedControl.selectedSegmentIndex = 0
        meanSearchCondSegmentedControl.selectedSegmentIndex = 0
        // ボタン選択時にボタンを選択状態にするかどうかの設定
        wordSearchCondSegmentedControl.isMomentary = false
        meanSearchCondSegmentedControl.isMomentary = false
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
            performSegue(withIdentifier: "returnToDictionaryViewController",sender: nil)
        }else if(sender.tag == 1){
            if(wordSearchCondSegmentedControl.selectedSegmentIndex == -1){
                showAlert(mes: "単語の検索条件を指定してください")
            }else{
                //単語の検索条件作成
                makeQuery(textfield: wordNameTextField,segmentedcontrol: wordSearchCondSegmentedControl,attribute: "word.wordName")
                //レベルの検索条件作成
                makeQuery(textfield: levelTextField,attribute: "word.level")
                //訳文の検索条件作成
                makeQuery(textfield: meanTextField,segmentedcontrol: meanSearchCondSegmentedControl,attribute: "mean")
                print(querylist)
                performSegue(withIdentifier: "toSearchResultViewController",sender: nil)
            }
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnToDictionaryViewController") {
            let _: DictionaryViewController = (segue.destination as? DictionaryViewController)!
        }else if(segue.identifier == "toSearchResultViewController"){
            let srVC: SearchResultViewController = (segue.destination as? SearchResultViewController)!
            srVC.querylist = querylist
        }
    }
    
    //指定された条件をもとにRealmへの検索条件を作成するメソッド
    func makeQuery(textfield: UITextField,segmentedcontrol: UISegmentedControl,attribute: String){
        //単語名検索の欄に何か入力されている場合、それに則り検索条件を作る
        if(!(textfield.text?.isEmpty)!){
            var wordquery = attribute + " "
            switch segmentedcontrol.selectedSegmentIndex {
            case 0: //前方一致
                wordquery.append("BEGINSWITH '")
                wordquery.append(textfield.text!)
                wordquery.append("'")
            case 1: //後方一致
                wordquery.append("ENDSWITH '")
                wordquery.append(textfield.text!)
                wordquery.append("'")
            case 2: //完全一致
                wordquery.append("= '")
                wordquery.append(textfield.text!)
                wordquery.append("'")
            default:
                //（基本ないが、何も選択されてない場合）→とりあえず完全一致にする
                wordquery.append("= '")
                wordquery.append(textfield.text!)
                wordquery.append("'")
            }
            querylist.append(wordquery)
        }
    }
    
    //指定された条件をもとにRealmへの検索条件を作成するメソッド
    func makeQuery(textfield: UITextField,attribute: String){
        //レベル検索の欄に何か入力されている場合、それに則り検索条件を作る
        if(!(textfield.text?.isEmpty)!){
            let query = attribute + " = " + textfield.text!
            querylist.append(query)
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
