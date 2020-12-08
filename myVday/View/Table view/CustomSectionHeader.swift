//
//  CustomSectionHeader.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/5.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

protocol CustomSectionHeaderDelegate: AnyObject {
    func sectionHeader(section header: CustomSectionHeader)
}

class CustomSectionHeader: UITableViewCell {

    weak var headerDelegate: CustomSectionHeaderDelegate?
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBAction func writeCommentBtn(_ sender: Any) {
        print("did tapped comment button.")
        headerDelegate?.sectionHeader(section: self)
    }
    
}
