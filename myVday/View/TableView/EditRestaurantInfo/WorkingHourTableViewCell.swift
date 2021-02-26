//
//  WorkingHourTableViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/2/25.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

import UIKit

class WorkingHourTableViewCell: UITableViewCell {
    
    static let identifier = "workingHourCell"

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourTextField: UITextField!
    @IBOutlet weak var fromHourPicker: UIDatePicker!
    @IBOutlet weak var toHourPicker: UIDatePicker!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
