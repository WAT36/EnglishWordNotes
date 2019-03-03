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
    @objc dynamic var wordNoteBookId: Int = 0
    @objc dynamic var wordNoteBookName: String = " "
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var option1: String = ""
    @objc dynamic var option2: String = ""
    @objc dynamic var option3: String = ""
    
    override static func primaryKey() -> String? {
        return "wordNoteBookId"
    }
    
    static func ==(a: WordNoteBook, b: WordNoteBook) -> Bool{
        return a.wordNoteBookId == b.wordNoteBookId && a.wordNoteBookName == a.wordNoteBookName
    }
}
