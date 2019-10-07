//
//  HomeViewController.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 07/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        presentLoginView()
    }
    
    func presentLoginView() {
        let loginVC = LoginViewController.instantiate(storyboardName: "Main")
        present(loginVC, animated: true)
    }

}
