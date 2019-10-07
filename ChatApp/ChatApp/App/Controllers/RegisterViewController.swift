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

    // MARK:- IBOutlet
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK:- IBAction
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard
            let username = usernameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text
        else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                print("ERROR: ", error!)
                return
            }
            let values = ["username": username, "email": email, "password": password]
            guard let uid = authResult?.user.uid else { return }
            
            let ref = Database.database().reference(fromURL: "https://ios-chat-apps.firebaseio.com/")
            let userReference = ref.child("users").child(uid)
            userReference.updateChildValues(values) { (err, ref) in
                if err != nil {
                    print("ERR: ", err!)
                    return
                }
                
                print("saved in db")
                self.dismiss(animated: true)
            }
            
        }
    }
    
    // MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
