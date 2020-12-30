//
//  DescribeTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/19.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class DescribeTableViewCell: UITableViewCell {

    static let identifier = "describeCell"
    @IBOutlet weak var restDescribeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
