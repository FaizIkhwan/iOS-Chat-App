//
//  Status.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 10/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Foundation

struct Status {
    var user : String
    var type : TypeOfPost
}

enum TypeOfPost {
    case note
    case image
    case video
}
