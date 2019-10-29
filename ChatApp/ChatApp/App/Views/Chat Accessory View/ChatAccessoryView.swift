//
//  ChatAccessoryView.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 29/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class ChatAccessoryView: UIView {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    static func getView(target: UIViewController, action: Selector) -> ChatAccessoryView? {
        let nib = ChatAccessoryView.nib()
        if let view = nib?.instantiate(withOwner: target, options: nil).first as?
            ChatAccessoryView {
            view.sendButton.addTarget(target, action: action, for: .touchUpInside)
            view.messageTextField.delegate = view.self
            return view
        } else {
            return nil
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        print("sendButtonPressed")
    }
}

extension ChatAccessoryView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("ChatAccessoryView textFieldShouldReturn")
//        handleSendMessage()
//        messageTextField.text = ""
        return true
    }
}

extension ChatAccessoryView: NibLoadable {
    static var NibName: String {
        return "ChatAccessoryView"
    }
}
