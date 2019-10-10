//
//  MainViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 10/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UITabBarController {

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    func presentLoginView() {
        let loginVC = LoginViewController.instantiate(storyboardName: Constant.Main)
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.modalTransitionStyle = .crossDissolve
        present(loginVC, animated: true)
    }
    
    // MARK: - Functions
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginView()
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child(Constant.users).child(uid).observeSingleEvent(of: .value, with: { (snapshots) in
                if let dic = snapshots.value as? [String: AnyObject] {
                    self.navigationItem.title = dic[User.Const.username] as? String
                }
            })
        }
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
}
