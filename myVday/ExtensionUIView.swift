//
//  ExtensionUIView.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/5/19.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

import UIKit

extension UIView {
    
    func buttonAlikeView() {
        self.layer.cornerRadius = 10.0
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0  //數字越大越不透明 越黑
        self.layer.shadowRadius = 10.0
    }
    
}
