//
//  ChallengeWithFriendTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/13.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class ChallengeWithFriendTableViewCell: UITableViewCell {
    
    let friendImageView = UIImageView()
    let friendNameLabel = UILabel()
    let imageManager = ImageManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        friendNameLabel.font = UIFont(name: "ChalkboardSE-Regular", size: 18)
        
        friendImageView.layer.cornerRadius = 20
        friendImageView.layer.masksToBounds = true
        friendImageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(friendImageView)
        contentView.addSubview(friendNameLabel)
        
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            friendImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            friendImageView.widthAnchor.constraint(equalToConstant: 40),
            friendImageView.heightAnchor.constraint(equalToConstant: 40),
            
            friendNameLabel.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 22),
            friendNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            friendNameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpChallengeFriendCell(with myFriend: User) {
        friendNameLabel.text = myFriend.nickname
        if myFriend.image.isEmpty {
            friendImageView.image = UIImage(named: "profile128")
        } else {
            imageManager.imageDelegate = self
            imageManager.downloadImage(imageSting: myFriend.image)
        }
    }
}

extension ChallengeWithFriendTableViewCell: ImageManagerDelegate {
    func imageManager(_ manager: ImageManager, getData image: Data) {
        DispatchQueue.main.async {
            self.friendImageView.image = UIImage(data: image)
        }
    }
}
