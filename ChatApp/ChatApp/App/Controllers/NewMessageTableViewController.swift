//
//  NewMessageTableViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 08/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {

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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NewMessageTableViewCell
        cell.usernameLabel.text = users[indexPath.row].username
        return cell
    }

    // MARK: - Functions
    
    func fetchUser() {
        Database.database().reference().child(Constant.users).observe(.childAdded) { (snapshots) in
            if let dic = snapshots.value as? [String: AnyObject] {
                let email = dic[User.Const.email] as? String ?? ""
                let password = dic[User.Const.password] as? String ?? ""
                let username = dic[User.Const.username] as? String ?? ""
                let user = User(email: email, password: password, username: username)
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }

}
