//
//  Word.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/16.
//  Copyright © 2019年 T.Wakasugi All rights reserved.
//

import Foundation
import RealmSwift

class Word: Object {
    @objc dynamic var wordName = " "
    @objc dynamic var createdDate = Date()
    @objc dynamic var numOfCorrect: Int = 0 //正答数
    @objc dynamic var numOfAnswer: Int = 0  //回答数
    @objc dynamic var option1: String = ""  //発音記号
    @objc dynamic var option2: String = ""  //レベル
    @objc dynamic var option3: String = ""
    
    override static func primaryKey() -> String? {
        return "wordName"
    }
    
    static func ==(a: Word, b: Word) -> Bool{
        return a.wordName == b.wordName
    }
    
}
