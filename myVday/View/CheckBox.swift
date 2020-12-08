//
//  CheckBox.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    
    var isChecked = false {
        didSet {
            if isChecked == false {
                self.layer.backgroundColor = UIColor.clear.cgColor
//                self.layer.borderColor = UIColor.black.cgColor
//                self.layer.borderWidth = 0
            } else {
                self.layer.backgroundColor = UIColor.lightGray.cgColor
//                self.layer.borderColor = UIColor.darkGray.cgColor
//                self.layer.borderWidth = 1
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
    
}
