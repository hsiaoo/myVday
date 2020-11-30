//
//  SearchRestaurantVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class SearchRestaurantVC: UIViewController {

    
    var isFilterBtnSelected = false {
        didSet {
            if isFilterBtnSelected == true {
                nameAddressTF.isEnabled = false
            } else {
                nameAddressTF.isEnabled = true
            }
        }
    }
    
    @IBOutlet weak var nameAddressTF: UITextField!
    
    @IBOutlet weak var tag1RightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tag1View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func filterBtnClicked(_ sender: UIButton) {
        isFilterBtnSelected = !isFilterBtnSelected
        if isFilterBtnSelected == true {
            tag1RightConstraint.constant = 0
            tag1View.isHidden = false
        } else {
            tag1RightConstraint.constant = 285
            tag1View.isHidden = true
        }
    }
    
}
