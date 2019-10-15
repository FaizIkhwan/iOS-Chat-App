//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import UIKit

class LoginViewController: UIViewController, Storyboarded {

    // MARK: - IBOutlet
                
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
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
    
    func handleAuthenticate(email: String, password: String) {
        self.activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let err = error {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error")
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true)
        }
    }
    
    func presentAlertController(withMessage message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in }
        alertController.addAction(okayAction)
        self.present(alertController, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func loginButton(_ sender: UIButton) {
        hideKeyboard()
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        if email.count == 0 || password.count == 0 {
            presentAlertController(withMessage: "Email and password cannot be empty", title: "Error")
        }
        if email.count < 3 {
            presentAlertController(withMessage: "Email to short", title: "Error")
            return
        }
        if password.count < 6 {
            presentAlertController(withMessage: "Password to short", title: "Error")
            return
        }
        
        handleAuthenticate(email: email, password: password)
    }
        
    deinit {
        print("Deinit - Login VC")
    }
}
