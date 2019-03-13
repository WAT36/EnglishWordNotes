//
//  Source.swift
//  EnglishWords
//
//  Created by T.Wakasugi on 2019/03/10.
//  Copyright © 2019年 T.Wakasugi. All rights reserved.
//

import Foundation
import RealmSwift

class Source: Object {
    @objc dynamic var sourceName: String = " "
    @objc dynamic var createdDate = Date()
    
    override static func primaryKey() -> String? {
        return "sourceName"
    }
    
    static func ==(a: Source, b: Source) -> Bool{
        return a.sourceName == b.sourceName
    }
}
