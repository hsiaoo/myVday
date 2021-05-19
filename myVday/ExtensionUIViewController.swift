//
//  ExtensionUIViewController.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/5/19.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static func confirmationAlert(title: String, message: String, handler: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let promptAction = UIAlertAction(title: "確定", style: .default) { _ in
            handler()
        }
        
        alertController.addAction(promptAction)
        
        return alertController
    }
}
