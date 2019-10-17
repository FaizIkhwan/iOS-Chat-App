//
//  ForgotPasswordViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 15/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import UIKit

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationAddObserver()
    }
    
    // MARK: - Keyboard Handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    fileprivate func animateKeyboard(constraintHeight: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.bottomConstraint.constant = constraintHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if notification.name == UIResponder.keyboardWillShowNotification {
            animateKeyboard(constraintHeight: -keyboardRect.height)
        } else {
            animateKeyboard(constraintHeight: 0)
        }
    }
    
    func hideKeyboard() {
        emailTextField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    func notificationAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Functions
    
    func handleResetPassword(withEmail email: String) {
        activityIndicator.startAnimating()
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let err = error {
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error", willDismiss: false)
                return
            }
            self.activityIndicator.stopAnimating()
            self.presentAlertController(withMessage: "Email sent", title: "Notice", willDismiss: true)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        guard let email = emailTextField.text else { return }
        if email.count == 0 {
            presentAlertController(withMessage: "Email cannot be empty", title: "Error", willDismiss: false)
            return
        }
        handleResetPassword(withEmail: email)
    }
    
    deinit {
        print("Deinit - Forgot Password VC")
    }
}
