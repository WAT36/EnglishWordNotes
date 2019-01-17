//
//  WordData.swift
//  EnglishWords
//
//  Created by Wataru Tsukagoshi on 2019/01/17.
//  Copyright © 2019年 Wataru Tsukagoshi. All rights reserved.
//

import Foundation
import RealmSwift

class WordData: Object{
    @objc dynamic var word: Word = Word()
    @objc dynamic var partofspeech: PartofSpeech = PartofSpeech()
    @objc dynamic var mean: String = " "
    @objc dynamic var source: String = " "
    @objc dynamic var example: String = " "
}
