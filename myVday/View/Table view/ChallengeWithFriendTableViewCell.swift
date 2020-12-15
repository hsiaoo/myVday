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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendNameLabel.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.backgroundColor = .yellow
        
        friendImageView.layer.cornerRadius = 20
        friendImageView.layer.masksToBounds = true
        
        contentView.addSubview(friendImageView)
        contentView.addSubview(friendNameLabel)
        
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            friendImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            friendImageView.widthAnchor.constraint(equalToConstant: 40),
            friendImageView.heightAnchor.constraint(equalToConstant: 40),
            
            friendNameLabel.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 20),
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

}
