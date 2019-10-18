//
//  NowSelectedDataManager.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/10/16.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation

class NowSelectedDataManager {
    
    var wordNoteBook: WordNoteBook
    var wordNote: WordNote
    var wordData: WordData
    var word: Word
 
    init(){
        self.wordNoteBook = WordNoteBook()
        self.wordNote = WordNote()
        self.wordData = WordData()
        self.word = Word()
    }
}
