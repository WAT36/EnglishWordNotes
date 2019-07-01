//
//  OptionConfigureWordNoteViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/07/01.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class OptionConfigureWordNoteViewController: UIViewController{
    
    @IBOutlet var viewName: UILabel!
    @IBOutlet var wordNameSegmentedControl: UISegmentedControl!

    var wordnotebook: WordNoteBook?
    
    var querykeylist: [String] = []
    var orderlist: [Bool] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面名ラベル設定、２行
        viewName.text = "単語帳設定\nオプション"
        viewName.numberOfLines = 2
        
        // ボタンを選択中にする場所を指定
        wordNameSegmentedControl.selectedSegmentIndex = 1
        // ボタン選択時にボタンを選択状態にするかどうかの設定
        wordNameSegmentedControl.isMomentary = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if(sender.tag == 1){
            makeQuery(segmentedcontrol: wordNameSegmentedControl, attribute: "word.wordName")
        }
        performSegue(withIdentifier: "returnToConfigureWordNoteViewController",sender: nil)
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "returnToConfigureWordNoteViewController") {
            let cwnbVC: ConfigureWordNoteBookViewController = (segue.destination as? ConfigureWordNoteBookViewController)!
            cwnbVC.wordnotebook = wordnotebook
            cwnbVC.querykeylist = querykeylist
            cwnbVC.orderlist = orderlist
        }
    }
    
    //指定された条件をもとにRealmへの検索条件を作成するメソッド
    func makeQuery(segmentedcontrol: UISegmentedControl,attribute: String){
        //ソート条件を作る
            switch segmentedcontrol.selectedSegmentIndex {
            case 0: //昇順
                querykeylist.append(attribute)
                orderlist.append(true)
            //case 1: //指定なし
            case 2: //降順
                querykeylist.append(attribute)
                orderlist.append(false)
            default:
                break
        }
    }
    
}
