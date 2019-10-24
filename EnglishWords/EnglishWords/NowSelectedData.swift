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
    
    var wordNoteSortBy: String      //単語帳ソート条件
    var wordNoteSortAscend: Bool    //単語帳ソート条件（昇降順）

    init(){
        self.wordNoteBook = WordNoteBook()
        self.wordNote = WordNote()
        self.wordData = WordData()
        self.word = Word()
        self.wordNoteSortBy = "word.wordName"   //デフォルトのソート条件
        self.wordNoteSortAscend = true          //デフォルトのソート条件
    }
}
