//
//  DayChallengeVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/20.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DayChallengeVC: UIViewController {
    
    @IBOutlet weak var editSaveBtn: UIBarButtonItem!
    @IBOutlet weak var dayChallengeCameraBtn: UIBarButtonItem!
    @IBOutlet weak var dayChallengeImageView: UIImageView!
    @IBOutlet weak var dayChaTitleTF: UITextField!
    @IBOutlet weak var dayChaDescribeTextView: UITextView!
    
    let fireManager = FirebaseManager()
    var isEditingDayChallenge = false
    var theChallenge: Challenge?
    var todayChallenge: DaysChallenge?
    var isMyChallengeData: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        keyboardHandling()
        if let okTodayChallenge = todayChallenge, let isMyData = isMyChallengeData {
            todayChaSetting(todayChallenge: okTodayChallenge)
            if isMyData == true {
                return
            } else {
                editSaveBtn.isEnabled = false
            }
        }
        
    }
    
    @IBAction func tappedEditSaveBtn(_ sender: Any) {
        isEditingDayChallenge = !isEditingDayChallenge
        if isEditingDayChallenge == false {
            saveDailyChallenge()
        } else {
            editDailyChallenge()
        }
    }
    
    @IBAction func tappedchaCameraBtn(_ sender: Any) {
        //camera and photo library
    }
    
    func todayChaSetting(todayChallenge: DaysChallenge) {
        dayChaTitleTF.text = todayChallenge.title
        dayChaDescribeTextView.text = todayChallenge.describe
        if todayChallenge.image.isEmpty {
            return
        } else {
            if let imageUrl = URL(string: todayChallenge.image) {
                URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                    if let err = error {
                        print("Error download image: \(err)")
                    }
                    if let okData = data {
                        DispatchQueue.main.async {
                            self.dayChallengeImageView.image = UIImage(data: okData)
                        }
                    }
                }.resume()
            }
        }
    }
    
    func editDailyChallenge() {
        editSaveBtn.image = UIImage(systemName: "checkmark.circle")
        dayChallengeCameraBtn.image = UIImage(systemName: "camera")
        dayChaTitleTF.isEnabled = true
        dayChaDescribeTextView.isEditable = true
    }
    
    func saveDailyChallenge() {
        editSaveBtn.image = UIImage(systemName: "pencil.circle")
        dayChallengeCameraBtn.image = nil
        dayChaTitleTF.isEnabled = false
        dayChaDescribeTextView.isEditable = false
        
        //challengeId, dayIndex, title, newDescribe, oldDescribe, okDays
        //from singlChallenge(theChallenge) -> challengeId, daysCompleted(okDays)
        //from todayChallenge -> oldDescribe, dayIndex
        //from user input -> title, newDescribe
        guard let newTitle = dayChaTitleTF.text,
            let newDescribe = dayChaDescribeTextView.text else { return }
        
        if let theCha = theChallenge, let todayCha = todayChallenge {
            let challengeId = theCha.challengeId
            let completedDays = theCha.daysCompleted
            let oldDescribe = todayCha.describe
            let dayIndex = todayCha.index
            
            fireManager.updateDailyChallenge(
                challengeId: challengeId,
                dayIndex: dayIndex,
                title: newTitle,
                newDescribe: newDescribe,
                oldDescribe: oldDescribe,
                completedDays: completedDays)
        }
    }
    
    func keyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
}

extension DayChallengeVC: FirebaseManagerDelegate {
}
