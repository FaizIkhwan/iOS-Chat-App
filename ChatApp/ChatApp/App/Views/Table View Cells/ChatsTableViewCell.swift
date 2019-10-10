//
//  ChatsTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 10/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var model: Chat? {
        didSet {
            guard let model = model else { return }
            usernameLabel.text = model.sender
            messageLabel.text = model.message
            timeLabel.text = model.time
        }
    }
}
