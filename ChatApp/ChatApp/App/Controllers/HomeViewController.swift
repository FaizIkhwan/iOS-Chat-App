//
//  HomeViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var profilePictureNavBarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameNavBarLabel: UILabel!
    
    // MARK: - Global Variable
    
    let cellID = "cellID"
    let NavigationControllerStoryboardID = "NavigationControllerNewMessage"
    
    var chats: [Chat] = []
    var chatsDictionary = [String: Chat]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // Remove extra separator in TableView
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profilePictureNavBarImageView.image = #imageLiteral(resourceName: "user")
        usernameNavBarLabel.text = ""
        checkIfUserIsLoggedIn()
        fetchMessages()
    }
    
    // MARK: - Functions        
    
    func fetchMessages() {
        let ref = Database.database().reference().child(Constant.chats).queryOrdered(byChild: Chat.Const.timestamp)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: String] {
                let chat = Chat(message: dict[Chat.Const.message, default: "No data"],
                                sender: dict[Chat.Const.sender, default: "No data"],
                                receiver: dict[Chat.Const.receiver, default: "No data"],
                                timestamp: dict[Chat.Const.timestamp, default: "No data"])
                                              
                guard let currentUserID = Auth.auth().currentUser?.uid else { return }
                
                if chat.receiver == currentUserID || chat.sender == currentUserID {
                    let partnerID = chat.receiver == currentUserID ? chat.sender : chat.receiver
                    self.chatsDictionary[partnerID] = chat
                    self.chats = Array(self.chatsDictionary.values)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginView()
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            fetchUser(childPath: uid) { (user) in
                guard let user = user else { return }
                self.setupNavBarTitle(user: user)
            }
        }
    }
    
    func fetchUser(childPath: String, completion: @escaping (User?) -> Void) {
        var user: User?
        Database.database().reference().child(Constant.users).child(childPath).observeSingleEvent(of: .value, with: { (snapshots) in
            if let dic = snapshots.value as? [String: String] {
                user = User(id: snapshots.key,
                                email: dic[User.Const.email, default: "No data"],
                                username: dic[User.Const.username, default: "No data"],
                                profileImageURL: dic[User.Const.profileImageURL, default: "No data"])
                completion(user)
            }
        })
    }

    func setupNavBarTitle(user: User) {
        profilePictureNavBarImageView.setImage(withURL: user.profileImageURL)
        usernameNavBarLabel.text = user.username
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    func presentChatController(user: User) {
        let chatVC = ChatLogViewController.instantiate(storyboardName: Constant.Main)
        chatVC.user = user
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func presentLoginView() {
        let loginVC = LoginViewController.instantiate(storyboardName: Constant.Main)
        loginVC.delegate = self
        present(loginVC, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        handleLogout()
        presentLoginView()
    }
        
    @IBAction func newMessageButtonPressed(_ sender: Any) {
        let newMessageVC = NewMessageTableViewController.instantiate(storyboardName: Constant.Main)
        newMessageVC.delegate = self
        newMessageVC.navigationItem.setHidesBackButton(true, animated: true)
        // TODO: REFACTOR?
        let storyboard = UIStoryboard(name: Constant.Main, bundle: nil)
        let destinationNavigationController = storyboard.instantiateViewController(withIdentifier: NavigationControllerStoryboardID) as! UINavigationController
        destinationNavigationController.pushViewController(newMessageVC, animated: true)
        destinationNavigationController.modalPresentationStyle = .fullScreen
        present(destinationNavigationController, animated: true)
    }
    
    deinit {
        print("Deinit - Home VC")
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! RecentChatTableViewCell
        cell.chat = chats[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let childPath = currentUserID == chats[indexPath.row].receiver ? chats[indexPath.row].sender : chats[indexPath.row].receiver
        
        fetchUser(childPath: childPath) { (user) in
            guard let user = user else { return }
            self.presentChatController(user: user)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension HomeViewController: NewMessageProtocol {
    func passUserToHomeVC(user: User) {
        presentChatController(user: user)
    }
}

extension HomeViewController: LoginViewProtocol {
    func emptyArrayDict() {
        chats.removeAll()
        chatsDictionary.removeAll()
    }
}
