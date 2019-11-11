//
//  RightChatVideoTableViewCell.swift
//  ChatApp
//
//  Created by Faiz Ikhwan on 01/11/2019.
//  Copyright © 2019 Faiz Ikhwan. All rights reserved.
//

import AVFoundation
import UIKit

class RightChatVideoTableViewCell: UITableViewCell {
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playButtonRight: UIButton!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var chat: Chat? {
        didSet {
            guard let url = chat?.imageURL else { return }
            messageImageView.setImage(withURL: url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicator.stopAnimating()
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if let videoUrlString = chat?.videoURL, let url = URL(string: videoUrlString) {
            playButtonRight.isHidden = true
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resize
            playerLayer?.frame = messageImageView.bounds
            messageImageView.layer.addSublayer(playerLayer!)
            player?.play()
        }
    }
}
