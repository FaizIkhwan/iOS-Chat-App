//
//  NewMessageTableViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 08/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class NewMessageTableViewController: UITableViewController {

    private var users: [User] = []
    private let cellId = "NewMessageTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NewMessageTableViewCell
        let user = users[indexPath.row]
        cell.usernameLabel.text = user.username
        
        if let profileImageURLString = user.profileImageURL {
            if let profileImageURL = URL(string: profileImageURLString) {
                cell.profilePictureImageView.sd_setImage(with: profileImageURL)
            }
        }
        
        return cell
    }

    // MARK: - Functions
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshots) in
            if let dic = snapshots.value as? [String: AnyObject] {
                let email = dic[User.Const.email] as? String ?? ""
                let password = dic[User.Const.password] as? String ?? ""
                let username = dic[User.Const.username] as? String ?? ""
                let profileImageURL = dic[User.Const.profileImageURL] as? String ?? ""
                let user = User(email: email, password: password, username: username, profileImageURL: profileImageURL)
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }

}
