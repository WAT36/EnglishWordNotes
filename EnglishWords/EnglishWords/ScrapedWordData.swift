//
//  ScrapedWordData.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/12/21.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation

class ScrapedWordData {
    
    var partofspeech:String
    var mean:String
    var ex_En:String
    var ex_Ja:String
    
    init() {
        self.partofspeech = " "
        self.mean = ""
        self.ex_En = ""
        self.ex_Ja = ""
    }
    
    func savePartOfSpeech(pos:String){
        self.partofspeech = pos
    }
    
    func getPartOfSpeech() -> String{
        return self.partofspeech
    }
    
    func saveMean(m:String){
        self.mean = m
    }
    
    func getMean() -> String{
        return self.mean
    }
    
    func saveExEn(exen:String){
        self.ex_En = exen
    }
    
    func getExEn() -> String{
        return self.ex_En
    }
    
    func saveExJa(exja:String){
        self.ex_Ja = exja
    }
    
    func getExJa() -> String{
        return self.ex_Ja
    }
}
