//
//  WordScraping.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/12/21.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import Kanna

class WordScraping {
    

    func scrapeWebsite(wordName: String) -> ScrapedWord{
        //入力されたテキストをtrim、また文中にスペース(=熟語)があったらそれを"+"にする
        var inputWord = wordName.trimmingCharacters(in: .whitespaces)
        inputWord = inputWord.replacingOccurrences(of: " ", with: "+")
        
        //取得したScrapedWord
        var resultOfWord:ScrapedWord = ScrapedWord()

        //Alamofireリクエスト待機用のセマフォ
        let semaphore = DispatchSemaphore(value: 0)
        let queue     = DispatchQueue.global(qos: .utility)
        
        //GETリクエスト 指定URLのコードを取得
        //入力した単語でスクレイピング開始
        let fqdn = "https://ejje.weblio.jp/content/" + inputWord
        Alamofire.request(fqdn).responseString(queue: queue) { response in
            print("\(response.result.isSuccess)")
            
            if !response.result.isSuccess {
                resultOfWord.setErrorFlag(result: true)
            }else if let html = response.result.value {
                //入力した単語でスクレイピング開始・テーブル更新
                resultOfWord = self.parseHTML(html: html)
                //取得完了したらセマフォでシグナル
                semaphore.signal()
            }
        }
        //スクレイピング結果取得完了するまで待つ
        semaphore.wait()
        
        return resultOfWord
    }
    
    func parseHTML(html: String) -> ScrapedWord{

        //スクレイピングしたWordDataを格納しておく配列
        let sw:ScrapedWord = ScrapedWord()

        if let doc = try? HTML(html: html, encoding: .utf8) {
            
            //単語のレベル取得
            var csstemp = doc.css("span[class='learning-level-content']")
            if(csstemp.count != 0){
                sw.saveLevel(l:csstemp.first!.text!)
            }
            //単語の発音記号取得
            csstemp = doc.css("span[class='phoneticEjjeDesc']")
            if(csstemp.count != 0){
                sw.savePronounce(p:csstemp.first!.text!)
            }
            //"level0"または"KejjeYrHd"のタグのみ抽出
            let means = doc.xpath("//div[@class='mainBlock hlt_KENEJ']/div[@class='kijiWrp']/div[@class='kiji']/div[@class='Kejje']//div[@class='level0' or @class='KejjeYrHd']")
            
            var state="partofspeech" //前に何を取得したかを示す状態。初期値はpartofspeech
            
            var wd:ScrapedWordData = ScrapedWordData()
            
            for m in means{
                
                //品詞のタグがある場合は品詞を入れる
                if(m.css("div[class='KnenjSub']").count > 0){
                    //品詞名を取得
                    var partofspeech:String = (m.css("div[class='KnenjSub']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    //サブ品詞を取得
                    let subpartofspeech = m.css("span[class='KejjeSm']").first?.text!
                    if( subpartofspeech != nil ){
                        //サブ品詞があったら品詞名を"品詞(サブ品詞)"にする
                        partofspeech = partofspeech.replacingOccurrences(of: subpartofspeech!, with: "")
                        partofspeech = partofspeech + "(" + (subpartofspeech?.trimmingCharacters(in: .whitespaces))! + ")"
                    }
                    
                    //ScrapedWordDataに品詞名を保存
                    if(state=="partofspeech"){
                        wd.savePartOfSpeech(pos: partofspeech)
                    }else{
                        sw.addWordData(worddata: wd)
                        wd=ScrapedWordData()
                        wd.savePartOfSpeech(pos: partofspeech)
                    }
                    state="partofspeech"
                }
                //意味のタグがある場合は意味を入れる
                else if(m.css("p[class='lvlB']").count > 0){
                    let b:String = (m.css("p[class='lvlB']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    
                    //ScrapedWordDataに意味を保存
                    if(state=="partofspeech"){
                        wd.saveMean(m: b)
                    }else{
                        let partofspeech=wd.getPartOfSpeech()
                        sw.addWordData(worddata: wd)
                        wd=ScrapedWordData()
                        wd.savePartOfSpeech(pos: partofspeech)
                        wd.saveMean(m: b)
                    }
                    state="mean"
                }
                //例文のタグがある場合は例文を入れる
                else if((m.css("span[class='KejjeYrEn']").count > 0) && (m.css("span[class='KejjeYrJp']").count > 0)){
                    //例文(英日)を取得
                    let exEn:String = (m.css("span[class='KejjeYrEn']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    let exJa:String = (m.css("span[class='KejjeYrJp']").first!.text?.trimmingCharacters(in: .whitespaces).uppercased())!
                    
                    //ScrapedWordDataに例文を保存
                    wd.saveExEn(exen: exEn)
                    wd.saveExJa(exja: exJa)
                    state="ex"
                }
                //そうでない場合・・
                else{
                    //品詞を取った直後なら、とりあえず意味として取る
                    if(state=="partofspeech"){
                        let b:String = m.content!
                        wd.saveMean(m: b)
                        state="mean"
                    }
                }
            }
            sw.addWordData(worddata: wd)
        }
        
        print("WordScraping.parseHTML: end")

        return sw
    }
}
