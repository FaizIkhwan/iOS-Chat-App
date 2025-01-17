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
                
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK:- Global Variable
    var homeViewController: HomeViewController?
    
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
                self.bottomConstraint.constant = -keyboardRect.height
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
  
    func hideKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    func notificationAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Functions
    
    func authenticate(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let err = error {
                // alert controller
                let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
                    
                }
                alertController.addAction(okayAction)
                self.present(alertController, animated: true)
                print("ERROR: ", err.localizedDescription)
                return
            }
            
            self.homeViewController?.fetchUserAndSetupNavBarTitle() // FIXME: tak read
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
    
    // HOMEWORK: Is this necessary on iOS version ??
    deinit {
        print("Deinit - Login VC")
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
