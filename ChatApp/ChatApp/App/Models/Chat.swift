//
//  Chat.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 14/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Foundation

struct Chat {
    let message: String
    let sender: String
    let receiver: String
    let timestamp: String
    
    enum Const {
        static let message = "message"
        static let sender = "sender"
        static let receiver = "receiver"
        static let timestamp = "timestamp"
    }
}
