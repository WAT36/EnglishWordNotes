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
    @objc dynamic var worddata: WordData?
    @objc dynamic var wordidx: Int = 0
    @objc dynamic var registereddate: Date = Date()
}
