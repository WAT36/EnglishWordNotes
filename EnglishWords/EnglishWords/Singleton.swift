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
    
    func allReset(){
        nowdata.wordNoteBook = WordNoteBook()
        nowdata.wordNote = WordNote()
        nowdata.wordData = WordData()
        nowdata.word = Word()
        
        nowdata.wordNoteSortBy = "word.wordName"
        nowdata.wordNoteSortAscend = true
        
        nowdata.isAddingNewWordData = false
        nowdata.addWordFromDictionary = false
    }
    
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
    
    func saveWordNoteSortBy(wnsb:String){
        nowdata.wordNoteSortBy = wnsb
    }
    
    func getWordNoteSortBy() -> String{
        return nowdata.wordNoteSortBy
    }
    
    func saveWordNoteSortAscend(wnsa:Bool){
        nowdata.wordNoteSortAscend = wnsa
    }
    
    func getWordNoteSortAscend() -> Bool{
        return nowdata.wordNoteSortAscend
    }
    
    func saveIsAddingNewWordData(ianwd:Bool){
        nowdata.isAddingNewWordData = ianwd
    }
    
    func getIsAddingNewWordData() -> Bool{
        return nowdata.isAddingNewWordData
    }
    
    func saveAddWordFromDictionary(awfd:Bool){
        nowdata.addWordFromDictionary = awfd
    }
    
    func getAddWordFromDictionary() -> Bool{
        return nowdata.addWordFromDictionary
    }
}
