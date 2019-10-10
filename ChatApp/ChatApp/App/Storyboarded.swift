//
//  Storyboarded.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

protocol Storyboarded {}

extension Storyboarded where Self: UIViewController {    
    static func instantiate(storyboardName: String) -> Self {
        let storyboardIdentifier = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

