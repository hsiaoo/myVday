//
//  FriendChallengeListTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/9.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class FriendChallengeListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var friendChallengeImageView: UIImageView!
    @IBOutlet weak var listTitleLabel: UILabel!
    @IBOutlet weak var listDescribeLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    
    static let identifier = "friendChallengeCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
