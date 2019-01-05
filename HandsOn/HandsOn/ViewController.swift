//
//  ViewController.swift
//  HandsOn
//
//  Created by Wataru Tsukagoshi on 2019/01/04.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //ラベルのインスタンス生成
    let testLabel = UILabel()
    
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()
        
        label.text = "Hello World!"
    }

    //回転を検知
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotationChange(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc
    func rotationChange(notification: NSNotification){
        setLabel()
    }
    
    func setLabel(){
        
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        
        //ラベルのサイズを設定
        testLabel.frame = CGRect(x:0, y:screenHeight-80, width:screenWidth, height:80);
        
        //ラベルの文字を設定
        testLabel.text = "(testLabel)Hello,World!"
        
        //ラベルの色を黒に設定
        testLabel.textColor = UIColor.black
        
        //ラベルのフォントを設定
        testLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        //わかりやすくするため背景色を設定
        testLabel.backgroundColor = UIColor(red:0.7, green:1.0, blue:0.9, alpha:1.0)
        
        //テキスト中央寄せ
        testLabel.textAlignment = NSTextAlignment.center
        
        //Viewにラベルを追加
        self.view.addSubview(testLabel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
}

