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
}
