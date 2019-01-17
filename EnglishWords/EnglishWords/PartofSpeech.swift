//
//  PartofSpeech.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/01/17.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift

class PartofSpeech: Object {
    @objc dynamic var partId = 0
    @objc dynamic var partName = " "
    @objc dynamic var createdDate = Date()
    
    override static func primaryKey() -> String? {
        return "partId"
    }
}
