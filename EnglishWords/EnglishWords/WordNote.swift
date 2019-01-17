//
//  WordNote.swift
//  EnglishWords
//
//  Created by Wataru Tsukagoshi on 2019/01/17.
//  Copyright © 2019年 Wataru Tsukagoshi. All rights reserved.
//

import Foundation
import RealmSwift

class WordNote: Object {
    @objc dynamic var wordnotebook: WordNoteBook = WordNoteBook()
    @objc dynamic var worddata: WordData = WordData()
    @objc dynamic var wordidx: Int = 0
    @objc dynamic var registereddate: Date = Date()
}
