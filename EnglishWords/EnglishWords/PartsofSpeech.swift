//
//  PartsofSpeech.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/28.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift

class PartsofSpeech: Object {
    @objc dynamic var partsOfSpeechId: Int = 0
    @objc dynamic var partsOfSpeechName: String = " "
    @objc dynamic var createdDate: Date = Date()
    
    override static func primaryKey() -> String? {
        return "partsOfSpeechId"
    }
    
    static func ==(a: PartsofSpeech, b: PartsofSpeech) -> Bool{
        return a.partsOfSpeechId == b.partsOfSpeechId
    }
}
