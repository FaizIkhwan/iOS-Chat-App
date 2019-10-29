//
//  NibLoadable.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 29/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

protocol NibLoadable {
    static var NibName: String { get }
}

extension NibLoadable {
    static func nib() -> UINib? {
        if NibName.count > 0 {
            return UINib(nibName: NibName, bundle: nil)
        } else {
            return nil
        }
    }
}
