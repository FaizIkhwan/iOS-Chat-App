//
//  RecentChatTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 14/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import UIKit

class RecentChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var chat: Chat? {
        didSet {
            guard let chat = chat else { return }
            let ref = Database.database().reference().child(Constant.users).child(chat.receiver)
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String: String] {
                    self.usernameLabel?.text = dict[User.Const.username, default: "No data"]
                    self.profileImageView.setImage(withURL: dict[User.Const.profileImageURL, default: "No data"])
                }
            }
            lastMessageLabel?.text = chat.message
            
            if let seconds = Double(chat.timestamp) {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
}
