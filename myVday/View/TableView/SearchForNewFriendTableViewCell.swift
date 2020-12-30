//
//  SearchForNewFriendTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/16.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class SearchForNewFriendTableViewCell: UITableViewCell {
    
    static let identifier = "newFriendCell"
    
    @IBOutlet weak var newFriendImageView: UIImageView!
    @IBOutlet weak var newFriendNameLabel: UILabel!
    @IBOutlet weak var newFriendBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newFriendImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
