//
//  UITextField_MyTextField.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class EmojiTextField: UITextField {
    
    //    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
    //
    //    override func awakeFromNib() {
    //        self.leftView = paddingView
    //        self.leftViewMode = .always
    //    }
    
    // required for iOS 13
    override var textInputContextIdentifier: String? { "" }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes where mode.primaryLanguage == "emoji" {
            return mode
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(inputModeDidChange),
                                               name: UITextInputMode.currentInputModeDidChangeNotification,
                                               object: nil)
    }
    
    @objc func inputModeDidChange(_ notification: Notification) {
        guard isFirstResponder else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.reloadInputViews()
        }
    }
    
}
