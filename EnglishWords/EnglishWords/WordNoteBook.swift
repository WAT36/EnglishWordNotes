//
//  WordNoteBook.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/16.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift

class WordNoteBook: Object {
    @objc dynamic var wordNoteBookId = 0
    @objc dynamic var wordNoteBookName = " "
    @objc dynamic var createdDate = Date()
    
    override static func primaryKey() -> String? {
        return "wordNoteBookId"
    }
}
