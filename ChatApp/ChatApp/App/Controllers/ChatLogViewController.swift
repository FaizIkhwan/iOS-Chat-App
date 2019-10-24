//
//  ChatLogViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 14/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import UIKit

class ChatLogViewController: UIViewController, Storyboarded {
            
    // MARK:- IBOutlet
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    // MARK:- Global Variable
    
    var chats: [Chat] = []
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        fetchMessages()
    }
    
    // MARK:- Functions
    
    func handleSendMessage() {
        let ref = Database.database().reference().child(Constant.chats)
        let childRef = ref.childByAutoId()
        let timestamp = String(NSDate().timeIntervalSince1970)
        let values: [String: String] = [Chat.Const.message: messageTextField.text ?? "",
                                        Chat.Const.sender: Auth.auth().currentUser?.uid ?? "",
                                        Chat.Const.receiver: user?.id ?? "",
                                        Chat.Const.timestamp: timestamp]
        childRef.updateChildValues(values)
    }
    
    func fetchMessages() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        guard let user = user else { return }
        let ref = Database.database().reference().child(Constant.chats).queryOrdered(byChild: Chat.Const.receiver).queryEqual(toValue: user.id)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: String] {
                let chat = Chat(message: dict[Chat.Const.message, default: "No data"],
                                sender: dict[Chat.Const.sender, default: "No data"],
                                receiver: dict[Chat.Const.receiver, default: "No data"],
                                timestamp: dict[Chat.Const.timestamp, default: "No data"])
                                                
                self.chats.append(chat)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK:- IBAction
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        handleSendMessage()
    }
    
    deinit {
        print("Deinit - Chat Log VC")
    }
}

extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}

extension ChatLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Auth.auth().currentUser?.uid == chats[indexPath.row].sender {
            let cell = Bundle.main.loadNibNamed("RightChatTableViewCell", owner: self, options: nil)?.first as! RightChatTableViewCell
            cell.chatLabel.text = chats[indexPath.row].message
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("LeftChatTableViewCell", owner: self, options: nil)?.first as! LeftChatTableViewCell
            cell.chatLabel.text = chats[indexPath.row].message
            return cell
        }
    }
}
