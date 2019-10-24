//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - IBOutlet
        
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Global Variable
    
    let databaseURL = "https://ios-chat-apps.firebaseio.com/"
    
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
    
    fileprivate func animateKeyboard(constraintHeight: CGFloat, alpha: CGFloat, isHidden: Bool) {
        UIImageView.animate(withDuration: 0.2, animations: {
            self.imageView.alpha = alpha
            self.bottomConstraint.constant = constraintHeight
            self.view.layoutIfNeeded()
        }, completion: { finished in
          if isHidden == true {
              self.imageView.isHidden = true
          }
        })
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if notification.name == UIResponder.keyboardWillShowNotification {
            animateKeyboard(constraintHeight: -keyboardRect.height, alpha: 0.0, isHidden: true)
        } else {
            self.imageView.isHidden = false
            animateKeyboard(constraintHeight: 0, alpha: 1.0, isHidden: false)
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
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error", willDismiss: false)
                return
            }
            self.handleUploadProfileImage(username: username, email: email, authResult: authResult)
        }
    }
    
    private func handleUploadProfileImage(username: String, email: String, authResult: AuthDataResult?) {
        let imageName = NSUUID().uuidString
        guard let uploadData = self.imageView.image?.jpegData(compressionQuality: 0.1) else { return }
        let storageRef = Storage.storage().reference().child(Constant.profileImages).child("\(imageName).jpg")
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let err = error {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error", willDismiss: false)
                return
            }
            self.fetchProfileImageDownloadURL(username: username, email: email, authResult: authResult, storageRef: storageRef)
        }
    }
    
    private func fetchProfileImageDownloadURL(username: String, email: String, authResult: AuthDataResult?, storageRef: StorageReference) {
        storageRef.downloadURL { (url, errorURL) in
            if let errURL = errorURL {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: errURL.localizedDescription, title: "Error", willDismiss: false)
                return
            }            
            guard let profileImageURL = url?.absoluteString else {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: "Failed to add profile image", title: "Error", willDismiss: false)
                return
            }
                                                                        
            guard let uid = authResult?.user.uid else {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: "Something has broken", title: "Error", willDismiss: false)
                return
            }
            
            let values = [User.Const.id: uid, User.Const.username: username, User.Const.email: email, User.Const.profileImageURL: profileImageURL] as [String : AnyObject]
            
            self.handleAddUserIntoDatabaseWithUID(uid, values: values)
        }
    }
    
    private func handleAddUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: databaseURL)
        let userReference = ref.child(Constant.users).child(uid)
        userReference.updateChildValues(values) { (error, ref) in
            if let err = error {
                self.activityIndicator.stopAnimating()
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error", willDismiss: false)
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true)
        }
    }
    
    private func setupImageView() {
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
                
        if username.count == 0 || email.count == 0 || password.count == 0 || confirmPassword.count == 0 {
            presentAlertController(withMessage: "Please fill all the form", title: "Error", willDismiss: false)
            return
        }
        if password != confirmPassword {
            presentAlertController(withMessage: "Password and confirm password does not match", title: "Error", willDismiss: false)
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
