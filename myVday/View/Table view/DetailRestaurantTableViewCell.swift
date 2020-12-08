//
//  DetailRestaurantTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class DetailRestaurantTableViewCell: UITableViewCell {
    
    static let identifier = "commentCell"
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    @IBOutlet weak var imageViewForComment: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
