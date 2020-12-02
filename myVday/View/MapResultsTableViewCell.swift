//
//  MapResultsTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/26.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hot1Label: UILabel!
    @IBOutlet weak var hot2Label: UILabel!
    @IBOutlet weak var tag1Label: UILabel!
    @IBOutlet weak var tag2Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
