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

    var isAddingNewWordData: Bool   //新しい訳文を追加する状態か（訳文設定画面で利用する）
    var addWordFromDictionary: Bool //単語の追加を辞書から行うかを示すフラグ（単語追加で利用する）
    
    var nowTestingWord: Word        //現在テストに出題している単語
    
    init(){
        self.wordNoteBook = WordNoteBook()
        self.wordNote = WordNote()
        self.wordData = WordData()
        self.word = Word()
        self.wordNoteSortBy = "word.wordName"   //デフォルトのソート条件
        self.wordNoteSortAscend = true          //デフォルトのソート条件
        self.isAddingNewWordData = false
        self.addWordFromDictionary = false
        self.nowTestingWord = Word()
    }
}
