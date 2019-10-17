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

class NewMessageTableViewController: UITableViewController, Storyboarded {

    // MARK: - Global Variable
        
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
        dismiss(animated: true) {
            print("dissmised")
//            let user = self.users[indexPath.row]
            // will do closure
        }
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
                let email = dic[User.Const.email, default: ""]
                let username = dic[User.Const.username, default: ""]
                let profileImageURL = dic[User.Const.profileImageURL, default: ""]
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
