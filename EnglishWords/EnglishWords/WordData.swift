//
//  WordData.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/17.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift

class WordData: Object{
    @objc dynamic var word: Word?
    @objc dynamic var partofspeech: PartsofSpeech?
    @objc dynamic var mean = " "
    @objc dynamic var source = " "
    @objc dynamic var example = " "
    
//    override static func primaryKey() -> String? {
//        return "word"
//    }
    
    static func ==(a: WordData, b: WordData) -> Bool{
        return a.word == b.word
    }
}
