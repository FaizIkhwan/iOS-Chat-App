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
            
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var messageInputView: ChatAccessoryView! = {
        let footerView = ChatAccessoryView.getView(target: self, action: #selector(handleSendMessage))
        return footerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return messageInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
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
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchMessages()
        notificationAddObserver()
        becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        print("keyboardDuration \(keyboardDuration)")
        if notification.name == UIResponder.keyboardWillShowNotification {
            self.bottomConstraint.constant = -keyboardRect.height
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
//            DispatchQueue.main.async {
//                self.scrollToBottom()
//            }
        } else {
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
//            DispatchQueue.main.async {
//                self.scrollToBottom()
//            }
        }
    }
    
    func hideKeyboard() {
        messageInputView.messageTextField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    func notificationAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- Functions
    
    @objc func handleSendMessage() {
        if messageInputView.messageTextField.text == "" {
            return
        }
        let ref = Database.database().reference().child(Constant.chats)
        let childRef = ref.childByAutoId()
        let timestamp = String(NSDate().timeIntervalSince1970)
        let values: [String: String] = [Chat.Const.message: messageInputView.messageTextField.text ?? "",
                                        Chat.Const.sender: Auth.auth().currentUser?.uid ?? "",
                                        Chat.Const.receiver: user?.id ?? "",
                                        Chat.Const.timestamp: timestamp]
        childRef.updateChildValues(values)
        hideKeyboard()
        messageInputView.messageTextField.text = ""
    }
        
    // FIXME: ???
    func fetchMessages() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        guard let user = user else { return }
        let ref = Database.database().reference().child(Constant.chats).queryOrdered(byChild: Chat.Const.timestamp)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: String] {
                let chat = Chat(message: dict[Chat.Const.message, default: "No data"],
                                sender: dict[Chat.Const.sender, default: "No data"],
                                receiver: dict[Chat.Const.receiver, default: "No data"],
                                timestamp: dict[Chat.Const.timestamp, default: "No data"])
                                                                    
                if (chat.receiver == currentUserID && chat.sender == user.id) || (chat.sender == currentUserID && chat.receiver == user.id) {
                    self.chats.append(chat)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            }
        }
    }
    
    func scrollToBottom() {
        let indexPath = IndexPath(row: chats.count-1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    deinit {
        print("Deinit - Chat Log VC")
    }
}

extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        messageInputView.messageTextField.text = ""
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
