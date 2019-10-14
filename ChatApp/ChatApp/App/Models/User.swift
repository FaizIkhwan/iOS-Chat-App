//
//  User.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 08/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

struct User {
    let id: String
    let email: String
    let password: String
    let username: String
    let profileImageURL: String?
    
    enum Const {
        static let id = "id"
        static let email = "email"
        static let password = "password"
        static let username = "username"
        static let profileImageURL = "profileImageURL"
    }
}
