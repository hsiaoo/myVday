//
//  UITextField_MyTextField.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class MyTextField: UITextField {
    
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
    
    override func awakeFromNib() {
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}
