//
//  Singleton.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/10/16.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation

class Singleton: NSObject {
    var nowdata = NowSelectedDataManager()
    
    static let sharedInstance: Singleton = Singleton()
    private override init() {}
    
    func saveWordNoteBook(wnb:WordNoteBook){
        nowdata.wordNoteBook = wnb
    }
    
    func getWordNoteBook() -> WordNoteBook{
        return nowdata.wordNoteBook
    }
    
    func saveWordNote(wn:WordNote){
        nowdata.wordNote = wn
    }
    
    func getWordNote() -> WordNote{
        return nowdata.wordNote
    }
    
    func saveWord(w:Word){
        nowdata.word = w
    }
    
    func getWord() -> Word{
        return nowdata.word
    }
    
    func saveWordData(wd:WordData){
        nowdata.wordData = wd
    }
    
    func getWordData() -> WordData{
        return nowdata.wordData
    }
}
