//
//  SettingsViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 10/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var settingTableView: UITableView!
    
    // MARK: - Global Variable
    
    let cellID = "settingCells"
    var userInfoHeader: UserInfoHeader!
    var listSection0: [String] = ["Starred Messages", "WhatsApp Web/Desktop"]
    var listSection1: [String] = ["Account", "Chats", "Notifications", "Data and Storage Usage"]
    var listSection2: [String] = ["Help", "Tell a Friend"]
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.dataSource = self
        settingTableView.delegate = self
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        settingTableView.tableHeaderView = userInfoHeader
        settingTableView.tableFooterView = UIView() // Remove extra separator in TableView
    }
    
    // MARK: - Navigation
    
    func presentLoginView() {
        let loginVC = LoginViewController.instantiate(storyboardName: Constant.Main)
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.modalTransitionStyle = .crossDissolve
        present(loginVC, animated: true)
    }
    
    // MARK: - Functions
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    // MARK: - IBAction
            
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        handleLogout()
        presentLoginView()
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return listSection0.count
        case 1:
            return listSection1.count
        case 2:
            return listSection2.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SettingsTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.descriptionLabel.text = listSection0[indexPath.row]
        case 1:
            cell.descriptionLabel.text = listSection1[indexPath.row]
        case 2:
            cell.descriptionLabel.text = listSection2[indexPath.row]
        default:
            break
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
}
