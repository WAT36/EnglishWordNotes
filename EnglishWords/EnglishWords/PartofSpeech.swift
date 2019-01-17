//
//  PartofSpeech.swift
//  EnglishWords
//
//  Created by Wataru Tsukagoshi on 2019/01/17.
//  Copyright © 2019年 Wataru Tsukagoshi. All rights reserved.
//

import Foundation
import RealmSwift

class PartofSpeech: Object {
    @objc dynamic var partId: Int = 0
    @objc dynamic var partName: String = " "
    @objc dynamic var createdDate: Date = Date()
}
