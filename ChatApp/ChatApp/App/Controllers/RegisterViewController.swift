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
        
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
        setupImageView()
    }
            
    override func viewDidLayoutSubviews() {
        imageView.cornerRadiusV = imageView.frame.size.height/2 // make the image circle
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
    
    func notificationAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Functions
    
    func handleRegister(username: String, email: String, password: String) {
        activityIndicator.startAnimating()
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let err = error {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error")
                return
            }
            
            // Profile image
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child(Constant.profile_images).child("\(imageName).jpg")
            if let uploadData = self.imageView.image?.jpegData(compressionQuality: 0.1) {
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if let err = error {
                        self.activityIndicator.stopAnimating()
                        self.presentAlertController(withMessage: err.localizedDescription, title: "Error")
                        return
                    }
                                        
                    storageRef.downloadURL { (url, errorURL) in
                        if let errURL = errorURL {
                            self.activityIndicator.stopAnimating()
                            self.presentAlertController(withMessage: errURL.localizedDescription, title: "Error")
                            return
                        }
                        
                        guard let profileImageURL = url?.absoluteString else {
                            self.activityIndicator.stopAnimating()
                            self.presentAlertController(withMessage: "Failed to add profile image", title: "Error")
                            return
                        }
                                                                        
                        let values = [User.Const.username: username, User.Const.email: email, User.Const.password: password, User.Const.profileImageURL: profileImageURL] as [String : AnyObject]
                        guard let uid = authResult?.user.uid else {
                            self.activityIndicator.stopAnimating()
                            self.presentAlertController(withMessage: "Something has broken", title: "Error")
                            return
                        }
                        
                        self.handleAddUserIntoDatabaseWithUID(uid, values: values)
                    }
                }
            }
        }
    }
    
    private func handleAddUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: "https://ios-chat-apps.firebaseio.com/")
        let userReference = ref.child(Constant.users).child(uid)
        userReference.updateChildValues(values) { (error, ref) in
            if let err = error {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error")
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true)
        }
    }
    
    func setupImageView() {
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
    }
        
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        hideKeyboard()
        guard
            let username = usernameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text
        else { return }
        
        // Validation
        if username.count == 0 || email.count == 0 || password.count == 0 || confirmPassword.count == 0 {
            presentAlertController(withMessage: "Please fill all the form", title: "Error")
            return
        }
        if password != confirmPassword {
            presentAlertController(withMessage: "Password and confirm password does not match", title: "Error")
            return
        }
        
        handleRegister(username: username, email: email, password: password)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
        
    deinit {
        print("Deinit - Register VC")
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imageView.image = selectedImage
        }
        
        dismiss(animated: true)
    }
}
