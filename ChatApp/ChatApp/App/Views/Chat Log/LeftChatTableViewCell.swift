//
//  LeftChatTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 23/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class LeftChatTableViewCell: UITableViewCell {
    @IBOutlet weak var chatLabel: UILabel!
    
    static func getView(target: UIViewController) -> LeftChatTableViewCell? {
        let nib = LeftChatTableViewCell.nib()
        if let view = nib?.instantiate(withOwner: target, options: nil).first as?
            LeftChatTableViewCell {
            return view
        } else {
            return nil
        }
    }
}

extension LeftChatTableViewCell: NibLoadable {
    static var NibName: String {
        return "LeftChatTableViewCell"
    }
}
