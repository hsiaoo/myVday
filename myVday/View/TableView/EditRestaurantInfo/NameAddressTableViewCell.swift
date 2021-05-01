//
//  NameAddressTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/2/25.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

import UIKit

class NameAddressTableViewCell: UITableViewCell {
    
    static let identifier = "nameAddressCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
