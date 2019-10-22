//
//  WordNote.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/17.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift

class WordNote: Object {
    @objc dynamic var wordnotebook: WordNoteBook?
    @objc dynamic var word: Word?
    @objc dynamic var wordidx: Int = -1
    @objc dynamic var registereddate: Date = Date()
    
    
    static func ==(a: WordNote, b: WordNote) -> Bool{
        return a.wordnotebook == b.wordnotebook && a.word == b.word
    }
}
