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
    
    override static func primaryKey() -> String? {
        return "wordName"
    }
    
}
