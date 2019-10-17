//
//  NewMessageTableViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 08/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import SDWebImage
import UIKit

protocol NewMessageProtocol {
    func passUserToHomeVC(user: User)
}

class NewMessageTableViewController: UITableViewController, Storyboarded {

    // MARK: - Global Variable
        
    var delegate: NewMessageProtocol? = nil
    private var users: [User] = []
    private let cellId = "NewMessageTableViewCell"
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.passUserToHomeVC(user: users[indexPath.row])
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NewMessageTableViewCell
        let user = users[indexPath.row]
        cell.usernameLabel.text = user.username
        
        if let profileImageURLString = user.profileImageURL {
            cell.profilePictureImageView.setImage(withURL: profileImageURLString)
        }
        
        return cell
    }

    // MARK: - Functions
    
    func fetchUser() {
        Database.database().reference().child(Constant.users).observe(.childAdded) { (snapshots) in
            if let dic = snapshots.value as? [String: String] {
                let email = dic[User.Const.email, default: "No data"]
                let username = dic[User.Const.username, default: "No data"]
                let profileImageURL = dic[User.Const.profileImageURL, default: "No data"]
                let user = User(id: snapshots.key, email: email, username: username, profileImageURL: profileImageURL)
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }

    deinit {
        print("Deinit - New Message VC")
    }
}
