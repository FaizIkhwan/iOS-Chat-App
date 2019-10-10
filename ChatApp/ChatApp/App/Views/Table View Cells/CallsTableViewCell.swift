//
//  CallsTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 10/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class CallsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var typeCallLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var model: Call? {
        didSet {
            guard let model = model else { return }
            phoneNumLabel.text = model.caller
            typeCallLabel.text = "\(model.type)"
            timeLabel.text = model.time
        }
    }
}
