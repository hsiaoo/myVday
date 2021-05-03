//
//  NewRestaurantVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseFirestore

class NewRestaurantVC: UIViewController {

    @IBOutlet weak var newRestaurantNameTF: UITextField!
    @IBOutlet weak var newRestaurantAddressTF: UITextField!
    
    let mapManager = MapManager()
    let firebaseManager = FirebaseManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapManager.delegate = self
        firebaseManager.delegate = self
        
    }
    
    @IBAction func tappedSaveRestBtn(_ sender: Any) {
        guard let newRestAddress = newRestaurantAddressTF.text,
              let newRestName = newRestaurantNameTF.text else { return }
        
        if newRestName.isEmpty || newRestAddress.isEmpty {
            newRestaurantAlert(status: .fail, title: "😶", message: "請填入新餐廳的名稱及地址")
        } else {
            //將地址轉換成座標
            mapManager.addressToCoordinate(newRestName: newRestName, newRestAddress: newRestAddress)
        }
        
    }
    
    func newRestaurantAlert(status: SuccessOrFail, title: String, message: String) {
        let newRestaurantAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let promptAction = UIAlertAction(title: "確定", style: .default) { _ in
            switch status {
            case .success: self.dismiss(animated: true, completion: nil)
            case .fail: break
            }
        }
        newRestaurantAlertController.addAction(promptAction)
        present(newRestaurantAlertController, animated: true, completion: nil)
    }
    
}

extension NewRestaurantVC: MapManagerDelegate {
    func mapManager(_ manager: MapManager, didGetCoordinate: CLPlacemark, name: String, address: String) {
        if let coordinate = didGetCoordinate.location?.coordinate {
            let newRestaurant = BasicInfo(
                address: address,
                describe: "",
                hashtags: ["", ""],
                hots: ["", ""],
                hours: ["", "", "", "", "", "", ""],
                restaurantId: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                name: name,
                phone: "")
            //取得座標後，將資料傳至firestore新增餐廳
            firebaseManager.addNewRestaurant(newRestData: newRestaurant) {
                self.newRestaurantAlert(status: .success, title: "🤩", message: "成功新增一間餐廳！")
            }
        }
    }
}

extension NewRestaurantVC: FirebaseManagerDelegate {
    
}
