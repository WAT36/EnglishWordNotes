//
//  ScrapedWord.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2020/01/08.
//  Copyright © 2020年 T.Wakasugi. All rights reserved.
//

import Foundation

class ScrapedWord {
    
    var level:String
    var pronounce:String
    var wordData:[ScrapedWordData]
    //TODO 独自エラークラス実装できるまでとりあえずエラー判定用に
    var errorFlag:Bool
    
    init() {
        self.level = ""
        self.pronounce = ""
        self.wordData = []
        self.errorFlag = false
    }
    
    func saveLevel(l:String){
        self.level = l
    }
    
    func getLevel() -> String{
        return self.level
    }
    
    func savePronounce(p:String){
        self.pronounce = p
    }
    
    func getPronounce() -> String{
        return self.pronounce
    }
    
    func addWordData(worddata:ScrapedWordData){
        self.wordData.append(worddata)
    }
    
    func getWordData() -> [ScrapedWordData]{
        return self.wordData
    }
    
    func removeWordData(index:Int){
        self.wordData.remove(at: index)
    }
    
    func setErrorFlag(result:Bool){
        self.errorFlag=result
    }
    
    func getErrorFlag() -> Bool{
        return self.errorFlag
    }
}
