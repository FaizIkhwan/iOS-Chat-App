//
//  UIViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 15/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlertController(withMessage message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in }
        alertController.addAction(okayAction)
        self.present(alertController, animated: true)
    }
    
    func presentAlertControllerAndDismiss(withMessage message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            self.dismiss(animated: true)
        }
        alertController.addAction(okayAction)
        self.present(alertController, animated: true)
    }        
}
