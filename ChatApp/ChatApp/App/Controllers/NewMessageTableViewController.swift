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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NewMessageTableViewCell
        cell.usernameLabel.text = "testt \(indexPath.row)"
        return cell
    }

    // MARK: - Functions
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshots) in
            if let dic = snapshots.value as? [String: AnyObject] {
//                let user = User()
//                user.setValuesForKeyWithDictionary(dic)
//                print(user)
            }
        }
    }

}
