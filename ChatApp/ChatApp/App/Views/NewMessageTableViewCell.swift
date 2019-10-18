//
//  NewMessageTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 08/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class NewMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            usernameLabel.text = user.username
            profilePictureImageView.setImage(withURL: user.profileImageURL)
        }
    }
}
