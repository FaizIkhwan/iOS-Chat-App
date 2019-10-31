//
//  RightChatImageTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 30/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class RightChatImageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageImageView: UIImageView!
    
    static func getView(target: UIViewController, action: Selector) -> RightChatImageTableViewCell? {
        let nib = RightChatImageTableViewCell.nib()
        if let view = nib?.instantiate(withOwner: target, options: nil).first as?
            RightChatImageTableViewCell {
            view.messageImageView.addGestureRecognizer(UIGestureRecognizer(target: target, action: action))
            return view
        } else {
            return nil
        }
    }
}

extension RightChatImageTableViewCell: NibLoadable {
    static var NibName: String {
        return "RightChatImageTableViewCell"
    }
}
