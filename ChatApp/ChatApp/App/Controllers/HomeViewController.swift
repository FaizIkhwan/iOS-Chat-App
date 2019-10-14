//
//  HomeViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

// import alphabetically
import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
        
    // MARK: - Global Variable
        
    var chats: [Chat] = []
    let cellID = "cellID"
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad HomeViewController")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        checkIfUserIsLoggedIn()
        observeMessages()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    // MARK: - Functions        
    
    func observeMessages() {
        let ref = Database.database().reference().child(Constant.chats)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let chat = Chat(message: dict[Chat.Const.message] as? String ?? "", sender: dict[Chat.Const.sender] as? String ?? "", receiver: dict[Chat.Const.receiver] as? String ?? "", timestamp: dict[Chat.Const.timestamp] as? String ?? "")
                self.chats.append(chat)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginView()
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child(Constant.users).child(uid).observeSingleEvent(of: .value, with: { (snapshots) in
            if let dic = snapshots.value as? [String: AnyObject] {
                let user = User(id: snapshots.key, email: dic[User.Const.email] as! String, password: dic[User.Const.password] as! String, username: dic[User.Const.username] as! String, profileImageURL: dic[User.Const.profileImageURL] as? String)
                self.setupNavBarWithUser(user: user)
            }
        })
    }
    
    func setupNavBarWithUser(user: User) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        containerView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.cornerRadiusV = 20
        if let url = URL(string: user.profileImageURL!) {
            profileImageView.sd_setImage(with: url)
        }
        
        // Constraint profileImageView
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.username
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraint nameLabel
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func showChatController(user: User) {
        print("showChatController")
        let chatVC = ChatLogViewController.instantiate(storyboardName: Constant.Main)
        chatVC.user = user
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func presentLoginView() {
        let loginVC = LoginViewController.instantiate(storyboardName: Constant.Main)
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.modalTransitionStyle = .crossDissolve
        present(loginVC, animated: true)
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        handleLogout()
        presentLoginView()
    }
        
    @IBAction func newMessageButtonPressed(_ sender: Any) {
        let newMessageVC = NewMessageTableViewController.instantiate(storyboardName: Constant.Main)
        present(newMessageVC, animated: true)
    }
    
    @IBAction func chatLogButtonPressed(_ sender: UIButton) {
        // HARD CODE
        let user = User(id: "TYVlACMnswWh0JghfiyBeDGq2Ij2", email: "test1@gmail.com", password: "123456", username: "faiz joker", profileImageURL: "https://firebasestorage.googleapis.com/v0/b/ios-chat-apps.appspot.com/o/profile_images%2F98D64492-C31E-4428-9E50-5CB9AF540802.png?alt=media&token=0d7ad306-5529-4fc8-8544-8f056e9f43a8")
        showChatController(user: user)
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
        let chat = chats[indexPath.row]
                
        let ref = Database.database().reference().child(Constant.users).child(chat.receiver)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                cell.usernameLabel?.text = dict[User.Const.username] as? String
            }
        }
        
        cell.lastMessageLabel?.text = chat.message
        
        return cell
    }
}
