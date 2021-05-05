//
//  PhoneTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/2/25.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

import UIKit

class PhoneTableViewCell: UITableViewCell {
    
    static let identifier = "phoneCell"
    
    @IBOutlet weak var numberTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}