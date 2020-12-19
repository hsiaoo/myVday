//
//  WriteCommentVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/19.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class WriteCommentVC: UIViewController {

    @IBOutlet weak var voteForCuisineTF: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    
    let firebaseManager = FirebaseManager()
    let votePicker = UIPickerView()
    var restaurantId: String?
    var allCuisineName = [String]()
    var favCuisine = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.delegate = self
        votePicker.delegate = self
        voteForCuisineTF.inputView = votePicker
        
        if let restId = restaurantId {
            firebaseManager.fetchSubCollections(restaurantId: restId, type: .menu)
        }
    }
    
    @IBAction func doneCommentBtn(_ sender: UIBarButtonItem) {
//        navigationController?.popViewController(animated: true)
        favCuisine = voteForCuisineTF.text ?? ""
        if commentTextView.text.isEmpty {
            print("======請輸入評論======")
        } else {
            //新增評論
            if let restId = restaurantId, let userName = UserDefaults.standard.string(forKey: "userNickname"), let comment = commentTextView.text {
                firebaseManager.addComment(toFirestoreWith: restId, nickname: userName, comment: comment)
            }
        }
        
        if favCuisine.isEmpty {
            return
        } else {
            if let restId = restaurantId {
                firebaseManager.fetchCertainCuisine(restaurantId: restId, cuisineName: favCuisine)
            }
        }
    }
    
}

extension WriteCommentVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        allCuisineName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        allCuisineName[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        voteForCuisineTF.text = allCuisineName[row]
    }
    
}

extension WriteCommentVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadDetail data: [QueryDocumentSnapshot], type: DataType) {
        //取得所有餐點名稱
        if type == .menu {
            for menu in data {
                let cuisineName = menu["cuisineName"] as? String ?? ""
                allCuisineName.append(cuisineName)
            }
        }
    }
    
    func fireManager(_ manager: FirebaseManager, didDownloadCuisine: [String: Any]) {
        //投票餐點
        if let currentVote = didDownloadCuisine["vote"] as? Int,
            let restId = restaurantId {
            firebaseManager.updateVote(restaurantId: restId, cuisineName: favCuisine, newValue: currentVote + 1)
        }
    }
}
