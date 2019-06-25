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
    @objc dynamic var meanidx: Int = -1
    @objc dynamic var mean = " "
    @objc dynamic var example_q = " "   //例文(問)
    @objc dynamic var example_a = " "   //例文(答)
    let source = List<Source>()         //出典のリスト

    
    static func ==(a: WordData, b: WordData) -> Bool{
        return a.word == b.word
    }
}
