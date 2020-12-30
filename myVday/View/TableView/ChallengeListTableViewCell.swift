//
//  ChallengeListTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/19.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class ChallengeListTableViewCell: UITableViewCell {
    
    static let identifier = "challengeListCell"
    @IBOutlet weak var challengeImageView: UIImageView!
    @IBOutlet weak var challengeTitleLabel: UILabel!
    @IBOutlet weak var challengeDescribeLabel: UILabel!
    @IBOutlet weak var challengeCheckmarkBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
