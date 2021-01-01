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
    
    @IBOutlet weak var dayChallengeEditSaveBtn: UIBarButtonItem!
    @IBOutlet weak var dayChallengeCameraBtn: UIBarButtonItem!
    @IBOutlet weak var dayChallengeImageView: UIImageView!
    @IBOutlet weak var dayChaTitleTF: UITextField!
    @IBOutlet weak var dayChaDescribeTextView: UITextView!
    
    let fireManager = FirebaseManager()
    var isEditingDayChallenge = false
    var isMyChallengeData: Bool?
    var theChallenge: Challenge?
    var todayChallenge: DaysChallenge?
    var selectedImage: UIImage?
    var downloadedImageString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        keyboardHandling()
        if let okTodayChallenge = todayChallenge, let isMyData = isMyChallengeData {
            todayChallengeSetting(todayChallenge: okTodayChallenge)
            if isMyData == true {
                return
            } else {
                dayChallengeEditSaveBtn.isEnabled = false
            }
        }
        
    }
    
    @IBAction func tappedEditSaveBtn(_ sender: Any) {
        isEditingDayChallenge = !isEditingDayChallenge
        if isEditingDayChallenge == false {
            saveDailyChallenge()
        } else {
//            editSaveBtn.isEnabled = false
            editDailyChallenge()
        }
    }
    
    @IBAction func tappedchaCameraBtn(_ sender: Any) {
        dayChallengeEditSaveBtn.isEnabled = false
        dayChaTitleTF.resignFirstResponder()
        dayChaDescribeTextView.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "上傳每日挑戰紀錄的照片", message: "請選擇照片來源", preferredStyle: .actionSheet)
        let imageFromLibraryAction = UIAlertAction(title: "照片圖庫", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.dayChallengeEditSaveBtn.isEnabled = true
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        
        imagePickerAlertController.addAction(imageFromLibraryAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    
    func todayChallengeSetting(todayChallenge: DaysChallenge) {
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
        dayChallengeEditSaveBtn.image = UIImage(systemName: "checkmark.circle")
        dayChallengeCameraBtn.image = UIImage(systemName: "camera")
        dayChaTitleTF.isEnabled = true
        dayChaDescribeTextView.isEditable = true
    }
    
    func saveDailyChallenge() {
        dayChallengeEditSaveBtn.image = UIImage(systemName: "pencil.circle")
        dayChallengeCameraBtn.image = nil
        dayChaTitleTF.isEnabled = false
        dayChaDescribeTextView.isEditable = false
        
        //challengeId, dayIndex, title, newDescribe, oldDescribe, okDays
        //from singlChallenge(theChallenge): challengeId, daysCompleted(okDays)
        //from todayChallenge: oldDescribe, dayIndex
        //from user input: title, newDescribe
        guard let newTitle = dayChaTitleTF.text,
            let newDescribe = dayChaDescribeTextView.text else { return }
        
        if let theCha = theChallenge, let todayCha = todayChallenge {
            let challengeId = theCha.challengeId
            let completedDays = theCha.daysCompleted
            let oldDescribe = todayCha.describe
            let dayIndex = todayCha.index
            let imageString = downloadedImageString ?? ""
            
            fireManager.updateDailyChallenge(
            challengeId: challengeId,
            dayIndex: dayIndex,
            title: newTitle,
            newDescribe: newDescribe,
            oldDescribe: oldDescribe,
            imageString: imageString,
            completedDays: completedDays)
        } else {
            print("=====單筆挑戰theChallenge和單日挑戰todayChallenge有問題=====")
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

extension DayChallengeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //顯示圖片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
            dayChallengeImageView.image = pickedImage
        }
        dismiss(animated: true) {
            //將圖片上傳至storage
            if let okChallenge = self.theChallenge,
                let okTodayChallenge = self.todayChallenge,
                let okImage = self.selectedImage {
                self.fireManager.uploadMenuChallengeImage(
                    restaurantChallengeId: okChallenge.challengeId,
                    imageNameString: okTodayChallenge.index.description,
                    selectedImage: okImage,
                    dataType: .challenge) { imageString in
                        self.downloadedImageString = imageString
                        self.dayChallengeEditSaveBtn.isEnabled = true
                        print("======成功上傳第\(okTodayChallenge.index)天的挑戰照片======")
                }
            }
        }
    }
}

//extension DayChallengeVC: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            print("no describe")
//        } else {
//            if selectedImage == nil {
//                editSaveBtn.isEnabled = true
//            }
//        }
//    }
//}

extension DayChallengeVC: FirebaseManagerDelegate {
}
