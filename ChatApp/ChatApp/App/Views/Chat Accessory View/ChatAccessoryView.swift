//
//  ChatAccessoryView.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 29/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class ChatAccessoryView: UIView {
    
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    static func getView(target: UIViewController, actionSendButton: Selector, actionImageButton: Selector) -> ChatAccessoryView? {
        let nib = ChatAccessoryView.nib()
        if let view = nib?.instantiate(withOwner: target, options: nil).first as?
            ChatAccessoryView {
            view.sendButton.addTarget(target, action: actionSendButton, for: .touchUpInside)
            view.galleryImageView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: actionImageButton))
            view.messageTextField.delegate = view.self
            return view
        } else {
            return nil
        }
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
