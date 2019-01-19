//
//  ViewController.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2018/09/16.
//  Copyright © 2018年 T.Wakasugi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table:UITableView!
    
    var TODO = ["aiueo","kakikukeko","sasisuseso"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return TODO.count + 1
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tablecell",
                                             for: indexPath)
        
        // Tag番号  で UILabel インスタンスの生成
        TODO.append("単語帳を追加")
        let label1 = cell.viewWithTag(1) as! UILabel
        label1.text = TODO[indexPath.row]
        
        return cell
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        // [indexPath.row] から画像名を探し、UImage を設定
        let selectedText = TODO[indexPath.row]
        if selectedText == "単語帳を追加" {
            // SubViewController へ遷移するために Segue を呼び出す
            performSegue(withIdentifier: "toSubViewController",sender: nil)
        }
    }
    
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSubViewController") {
            let _: AddWordNoteBookViewController = (segue.destination as? AddWordNoteBookViewController)!
        }
    }
}

