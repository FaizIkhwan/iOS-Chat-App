//
//  LeftChatImageTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 30/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class LeftChatImageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageImageView: UIImageView!
    
    static func getView(target: UIViewController, action: Selector) -> LeftChatImageTableViewCell? {
        let nib = LeftChatImageTableViewCell.nib()
        if let view = nib?.instantiate(withOwner: target, options: nil).first as?
            LeftChatImageTableViewCell {
            view.messageImageView.addGestureRecognizer(UIGestureRecognizer(target: target, action: action))
            return view
        } else {
            return nil
        }
    }
}

extension LeftChatImageTableViewCell: NibLoadable {
    static var NibName: String {
        return "LeftChatImageTableViewCell"
    }
}
