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
    dynamic var wordNoteBookId: Int = 0
    dynamic var wordNoteBookName: String = " "
    dynamic var createdDate: Date = "1990-01-01"
}
