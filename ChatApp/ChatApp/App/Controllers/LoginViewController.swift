//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, Storyboarded {

    // MARK: - IBOutlet
    
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationAddObserver()
    }
    
    // MARK: - Keyboard Handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if notification.name == UIResponder.keyboardWillShowNotification {
            UIView.animate(withDuration: 0.2) {
                self.formStackView.frame.origin.y = self.view.frame.size.height - keyboardRect.height - self.formStackView.frame.size.height
            }
        } else {            
            UIView.animate(withDuration: 0.2) {
                self.formStackView.frame.origin.y = (self.view.frame.size.height - self.formStackView.frame.size.height)/2
            }
        }
    }
  
    func hideKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    // HOMEWORK: Is this necessary on iOS version ??
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func notificationAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - Functions
    
    func authenticate(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let err = error {
                print("ERROR: ", err)
                return
            }
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func loginButton(_ sender: UIButton) {
        hideKeyboard()
        
        guard let email = emailTextField.text, email.count > 4 else {
            // alert
            return
        }
            
        guard let password = passwordTextField.text, password.count > 4 else {
            print("Form is not valid")
            return
        }
        // Validate input first
        authenticate(email: email, password: password)
    }
}
