//
//  AlertAction.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/10/13.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import UIKit

class AlertAction {
    
    //エラーアラートを出させる関数
    func showErrorAlert(vc: UIViewController, m: String) {
        // アラートを作成
        let alert = UIAlertController(
            title: "エラー",
            message: m,
            preferredStyle: .alert)
        
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // アラート表示
        vc.present(alert, animated: true, completion: nil)
    }
    
    // 最後の単語が終わった時にアラートを表示するメソッド
    func testEndDispAlert(vc: UIViewController, identifier: String) {
        
        //アラートの設定
        let alert: UIAlertController = UIAlertController(title: "テストが終了しました", message: "単語帳設定画面へ戻ります", preferredStyle:  UIAlertControllerStyle.alert)
        
        //OKボタン
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            vc.performSegue(withIdentifier: identifier, sender: nil)
        })
        
        //アラートにボタンをつける
        alert.addAction(okAction)
        
        //アラートを表示
        vc.present(alert, animated: true, completion: nil)
    }
}
