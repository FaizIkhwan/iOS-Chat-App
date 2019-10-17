//
//  UIImageVIew.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 14/10/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import SDWebImage
import UIKit

extension UIImageView {
    func setImage(withURL url: String) {
        guard let url = URL(string: url) else { return }
        let placeholderImage = #imageLiteral(resourceName: "user")
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: .fromCacheOnly)
    }
}
