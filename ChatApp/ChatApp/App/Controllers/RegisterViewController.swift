//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    // MARK: - IBOutlet
        
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
            UIImageView.animate(withDuration: 0.2, animations: {
                self.imageView.alpha = 0.0
                self.bottomConstraint.constant = -keyboardRect.height
                self.view.layoutIfNeeded()
            }) { (finished) in
                self.imageView.isHidden = true
            }
        } else {
            self.imageView.isHidden = false
            UIImageView.animate(withDuration: 0.2, animations: {
                self.imageView.alpha = 1.0
                self.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func hideKeyboard() {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    // HOMEWORK: Is this necessary on iOS version ??
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func notificationAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Functions
    
    func authentication(username: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print("ERROR: ", error!)
                return
            }
            let values = [User.Const.username: username, User.Const.email: email, User.Const.password: password]
            guard let uid = authResult?.user.uid else { return }
            
            let ref = Database.database().reference(fromURL: "https://ios-chat-apps.firebaseio.com/")
            let userReference = ref.child("users").child(uid)
            userReference.updateChildValues(values) { (err, ref) in
                if err != nil {
                    print("ERR: ", err!)
                    return
                }
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        hideKeyboard()
        guard
            let username = usernameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text
        else {
            // alert
            return
        }
        // Validate input first
        authentication(username: username, email: email, password: password)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
