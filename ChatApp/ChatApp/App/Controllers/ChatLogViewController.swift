//
//  ChatLogViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 14/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import Firebase
import UIKit

class ChatLogViewController: UIViewController, Storyboarded {
            
    // MARK:- IBOutlet
            
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var messageInputView: ChatAccessoryView! = {
        let footerView = ChatAccessoryView.getView(target: self, actionSendButton: #selector(handleSendMessage), actionImageButton: #selector(presentImagePicker))
        return footerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return messageInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK:- Global Variable
        
    let databaseURL = "https://ios-chat-apps.firebaseio.com/"
    var chats: [Chat] = []
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchMessages()
        notificationAddObserver()
        becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Handler
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        if notification.name == UIResponder.keyboardWillShowNotification {
            self.bottomConstraint.constant = -keyboardRect.height
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
//            DispatchQueue.main.async {
//                self.scrollToBottom()
//            }
        } else {
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
//            DispatchQueue.main.async {
//                self.scrollToBottom()
//            }
        }
    }
    
    func hideKeyboard() {
        messageInputView.messageTextField.resignFirstResponder()
    }
    
    // MARK: - Notifications
    
    func notificationAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- Functions
    
    @objc func handleSendMessage() {
        if messageInputView.messageTextField.text == "" {
            return
        }
        let ref = Database.database().reference().child(Constant.chats)
        let childRef = ref.childByAutoId()
        let timestamp = String(NSDate().timeIntervalSince1970)
        let values: [String: String] = [Chat.Const.message: messageInputView.messageTextField.text ?? "",
                                        Chat.Const.sender: Auth.auth().currentUser?.uid ?? "",
                                        Chat.Const.receiver: user?.id ?? "",
                                        Chat.Const.timestamp: timestamp]
        childRef.updateChildValues(values)
        hideKeyboard()
        messageInputView.messageTextField.text = ""
    }
        
    // FIXME: ???
    func fetchMessages() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        guard let user = user else { return }
        let ref = Database.database().reference().child(Constant.chats).queryOrdered(byChild: Chat.Const.timestamp)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: String] {
                let chat = Chat(message: dict[Chat.Const.message],
                                sender: dict[Chat.Const.sender]!,
                                receiver: dict[Chat.Const.receiver]!,
                                timestamp: dict[Chat.Const.timestamp]!,
                                imageURL: dict[Chat.Const.imageURL])
                                                                    
                if (chat.receiver == currentUserID && chat.sender == user.id) || (chat.sender == currentUserID && chat.receiver == user.id) {
                    self.chats.append(chat)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                }
            }
        }
    }
    
    func scrollToBottom() {
        let indexPath = IndexPath(row: chats.count-1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func uploadImageToFirebase(_ selectedImage: UIImage) {
        let imageName = NSUUID().uuidString
        guard let uploadData = selectedImage.jpegData(compressionQuality: 0.1) else { return }
        let storageRef = Storage.storage().reference().child(Constant.messageImages).child("\(imageName).jpg")
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let err = error {
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error", willDismiss: false)
                return
            }
            self.fetchImageURL(storageRef)
        }
    }
    
    private func fetchImageURL(_ storageRef: StorageReference) {
        storageRef.downloadURL { (url, error) in
            if let err = error {
                self.presentAlertController(withMessage: err.localizedDescription, title: "Error", willDismiss: false)
                return
            }
            
            guard let imageURL = url?.absoluteString else {
                self.presentAlertController(withMessage: "Failed to add profile image", title: "Error", willDismiss: false)
                return
            }
                                                                        
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                self.presentAlertController(withMessage: "Something has broken", title: "Error", willDismiss: false)
                return
            }
            let timestamp = String(NSDate().timeIntervalSince1970)
            let values = [
                Chat.Const.imageURL: imageURL,
                Chat.Const.receiver: self.user?.id ?? "",
                Chat.Const.sender: currentUserID,
                Chat.Const.timestamp: timestamp
            ]
            
            self.handleSendImageIntoDatabase(currentUserID, values: values)
        }
    }
    
    private func handleSendImageIntoDatabase(_ currentUserID: String, values: [String: String]) {
        let ref = Database.database().reference().child(Constant.chats)
        let childRef = ref.childByAutoId()
        childRef.updateChildValues(values)
    }
    
    deinit {
        print("Deinit - Chat Log VC")
    }
}

extension ChatLogViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            uploadImageToFirebase(selectedImage)
        }
        
        dismiss(animated: true)
    }
}

extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
        messageInputView.messageTextField.text = ""
        return true
    }
}

extension ChatLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        if Auth.auth().currentUser?.uid == chats[indexPath.row].sender {
            if let imageMessage = chats[indexPath.row].imageURL {
                let cell = Bundle.main.loadNibNamed("RightChatImageTableViewCell", owner: self, options: nil)?.first as! RightChatImageTableViewCell
                cell.messageImageView.setImage(withURL: imageMessage)
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("RightChatTableViewCell", owner: self, options: nil)?.first as! RightChatTableViewCell
                cell.chatLabel.text = chats[indexPath.row].message
                return cell
            }
        } else {
            if let imageMessage = chats[indexPath.row].imageURL {
                let cell = Bundle.main.loadNibNamed("LeftChatImageTableViewCell", owner: self, options: nil)?.first as! LeftChatImageTableViewCell
                cell.messageImageView.setImage(withURL: imageMessage)
                return cell
            } else {
                let cell = Bundle.main.loadNibNamed("LeftChatTableViewCell", owner: self, options: nil)?.first as! LeftChatTableViewCell
                cell.chatLabel.text = chats[indexPath.row].message
                return cell
            }
        }
    }
}
