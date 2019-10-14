//
//  ChatLogViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 14/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController, Storyboarded {
    
    // MARK:- Global Variable
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    // MARK:- IBOutlet
    
    @IBOutlet weak var messageTextField: UITextField!
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatLogViewController viewDidLoad")
        
        messageTextField?.delegate = self
    }
    
    // MARK:- Functions
    
    func handleSendMessage() {
        let ref = Database.database().reference().child("Chats")
        let childRef = ref.childByAutoId()
        let timestamp = String(NSDate().timeIntervalSince1970)
        let values = ["message": messageTextField.text!, "sender": Auth.auth().currentUser?.uid, "recipient": user!.id, "timestamp": timestamp]
        childRef.updateChildValues(values)
    }
    
    // MARK:- IBAction
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        handleSendMessage()
    }
}

extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
}
