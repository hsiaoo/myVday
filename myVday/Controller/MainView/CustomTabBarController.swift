//
//  CustomTabBarController.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/20.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func longPressRecog(_ sender: UILongPressGestureRecognizer) {
        //強制先跳轉畫面至MapVC，再彈出新增餐廳的畫面
        self.selectedIndex = 1
        if let navicontrollers = self.viewControllers,
            let secondnc = navicontrollers[1] as? UINavigationController,
            let mapvc = secondnc.viewControllers.first as? MapVC {
            mapvc.performSegue(withIdentifier: "newRestaurantSegue", sender: nil)
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //set 'tag' of tabBarItem in interface builder not programmatically in this case
        //只有長按第二個tab bar時才會觸發手勢
        if tabBar.selectedItem?.tag == 0 {
            return false
        } else {
            return true
        }
    }
    
}
