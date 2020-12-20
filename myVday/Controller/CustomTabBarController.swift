//
//  CustomTabBarController.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/20.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

//protocol CustomLongPressGestureDelegate: class {
//    func longPressForAddNewRest(_ tabBarController: CustomTabBarController)
//}

class CustomTabBarController: UITabBarController {
    
//    weak var longPressDelegate: CustomLongPressGestureDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func longPressRecog(_ sender: UILongPressGestureRecognizer) {
        self.selectedIndex = 1
        if let navicontrollers = self.viewControllers, let secondnc = navicontrollers[1] as? UINavigationController, let mapvc = secondnc.viewControllers.first as? MapVC {
            mapvc.moveAddingRestViewUp()
        }
        print("======long press======")
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //set 'tag' of tabBarItem in interface builder not programmatically in this case
        if tabBar.selectedItem?.tag == 0 {
            return false
        } else {
            return true
        }
    }
    
}
