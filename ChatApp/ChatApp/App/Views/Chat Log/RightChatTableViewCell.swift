//
//  RightChatTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 24/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class RightChatTableViewCell: UITableViewCell {
    @IBOutlet weak var chatLabel: UILabel!
    
    static func getView(target: UIViewController) -> RightChatTableViewCell? {
        let nib = RightChatTableViewCell.nib()
        if let view = nib?.instantiate(withOwner: target, options: nil).first as?
            RightChatTableViewCell {
            return view
        } else {
            return nil
        }
    }
}

extension RightChatTableViewCell: NibLoadable {
    static var NibName: String {
        return "RightChatTableViewCell"
    }
}
