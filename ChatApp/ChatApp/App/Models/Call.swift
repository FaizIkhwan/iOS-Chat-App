//
//  Call.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 10/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Foundation

struct Call {
    var caller : String
    var time : String
    var date : String
    var type : TypeOfCall
}

enum TypeOfCall : String{
    case incoming
    case outgoing
}
