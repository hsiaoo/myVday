//
//  ProfileVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/9.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

enum ProfileStatus {
    case success, fail
}

enum ProfileImageStatus {
    case old, new
}

class ProfileVC: UIViewController {
    
    @IBAction func signOutBtn(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(nil, forKey: "appleUserIDCredential")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "SignInViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    @IBOutlet weak var profleEditingView: UIView!
    @IBOutlet weak var profileNickNameTF: UITextField!
    @IBOutlet weak var profileDescribeTF: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileEmojiTF: UITextField!
    
    @IBOutlet weak var editSaveBarBtn: UIBarButtonItem!
    @IBOutlet weak var profileCameraBtn: UIBarButtonItem!
    
    @IBOutlet weak var friendBtnsView: UIView!
    @IBOutlet weak var challengeBtnsView: UIView!
    
    @IBOutlet var friendChallengeBtns: [UIButton]!
    
    let fireManager = FirebaseManager()
    var profileData: User?
    var isEditingProfile = false
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fireManager.delegate = self
        
        friendBtnsView.layer.cornerRadius = 10.0
        friendBtnsView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        friendBtnsView.layer.shadowOffset = CGSize(width: 0, height: 3)
        friendBtnsView.layer.shadowOpacity = 1.0
        friendBtnsView.layer.shadowRadius = 10.0
        friendBtnsView.layer.masksToBounds = false
        
        challengeBtnsView.layer.cornerRadius = 10.0
        challengeBtnsView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        challengeBtnsView.layer.shadowOffset = CGSize(width: 0, height: 3)
        challengeBtnsView.layer.shadowOpacity = 1.0
        challengeBtnsView.layer.shadowRadius = 10.0
        challengeBtnsView.layer.masksToBounds = false
        
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            fireManager.fetchProfileData(userId: userId)
        }
    }
    
    @IBAction func editProfileBtn(_ sender: Any) {
        isEditingProfile = !isEditingProfile
        
        if isEditingProfile == true {
            profileNickNameTF.isEnabled = true
            profileDescribeTF.isEnabled = true
            profileEmojiTF.isEnabled = true
            profileNickNameTF.becomeFirstResponder()
            editSaveBarBtn.image = UIImage(systemName: "checkmark.circle")
            profileCameraBtn.image = UIImage(systemName: "camera")
            for button in friendChallengeBtns {
                button.isEnabled = false
            }
        } else {
//            profileNickNameTF.isEnabled = false
//            profileDescribeTF.isEnabled = false
//            profileEmojiTF.isEnabled = false
//            editSaveBarBtn.image = UIImage(systemName: "pencil")
//            profileCameraBtn.image = nil
//            profileCameraBtn.image = nil
//            for button in friendChallengeBtns {
//                button.isEnabled = true
//            }
//            profileNickNameTF.resignFirstResponder()
//            profileDescribeTF.resignFirstResponder()
//            profileEmojiTF.resignFirstResponder()
            
            let newNickname = profileNickNameTF.text ?? ""
            let newDescribe = profileDescribeTF.text ?? ""
            let newEmoji = profileEmojiTF.text ?? "😃"
            let newEmojiString = emojiEncode(emoji: newEmoji)
            
            if newNickname.isEmpty {
                profileAlert(status: .fail, title: "😶", message: "請輸入暱稱")
            } else {
                if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                    if profileImageView.image != nil && selectedImage == nil {
                        //原本就有照片，但使用者這次沒有更新照片
                        let newProfileData = User(
                            userId: userId,
                            nickname: newNickname,
                            describe: newDescribe,
                            emoji: newEmojiString,
                            image: "")
                        self.fireManager.updateProfile(imageStauts: .old, profileData: newProfileData, completion: {
                            self.profileAlert(status: .success, title: "😎", message: "成功更新個人資料！")
                            UserDefaults.standard.set(newNickname, forKey: "userNickname")
                            print("=====\(newNickname)=====")
                        })
                    } else if selectedImage != nil {
                        //使用者這次修改有更新照片
                        if let newProfileImage = selectedImage {
                            fireManager.uploadProfileImage(userId: userId, profileImage: newProfileImage) { (imageString) in
                                let newProfileData = User(
                                    userId: userId,
                                    nickname: newNickname,
                                    describe: newDescribe,
                                    emoji: newEmojiString,
                                    image: imageString)
                                self.fireManager.updateProfile(imageStauts: .new, profileData: newProfileData, completion: {
                                    self.profileAlert(status: .success, title: "😎", message: "成功更新個人資料！")
                                    UserDefaults.standard.set(newNickname, forKey: "userNickname")
                                    print("=====\(newNickname)=====")
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addProfilePicBtn(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "上傳照片", message: "請選擇照片來源", preferredStyle: .actionSheet)
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCamaraAction = UIAlertAction(title: "相機", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCamaraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    
    @IBAction func friendBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "friendSegue", sender: profileData)
    }
    
    @IBAction func challengeBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "challengeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendSegue" {
            if let controller = segue.destination as? FriendListVC {
                controller.userData = sender as? User
            }
        } else {
            _  = segue.destination as? ChallengeListVC
        }
    }
    
    func profileSetting(userData: User) {
        if isEditingProfile == false {
            profileNickNameTF.text = userData.nickname
            profileDescribeTF.text = userData.describe
            profileEmojiTF.text = emojiDecode(emojiString: userData.emoji)
            
            //下載並使用者的照片
            if userData.image.isEmpty {
                return
            } else {
                //display user photo
                if let imageUrl = URL(string: userData.image) {
                    URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                        if let err = error {
                            print("Error download user photo: \(err)")
                        }
                        if let okData = data {
                            DispatchQueue.main.async {
                                self.profileImageView.image = UIImage(data: okData)
                            }
                        }
                    }.resume()
                }
            }
        } else {
            //使用者正在編輯資料，不須處理任何事
            return
        }
    }
    
    func profileAlert(status: ProfileStatus, title: String, message: String) {
        let profileAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let promptAction = UIAlertAction(title: "確定", style: .default) { _ in
            switch status {
            case .success:
                self.profileNickNameTF.resignFirstResponder()
                self.profileDescribeTF.resignFirstResponder()
                self.profileEmojiTF.resignFirstResponder()
                self.profileNickNameTF.isEnabled = false
                self.profileDescribeTF.isEnabled = false
                self.profileEmojiTF.isEnabled = false
                self.editSaveBarBtn.image = UIImage(systemName: "pencil")
                self.profileCameraBtn.image = nil
                self.profileCameraBtn.image = nil
                for button in self.friendChallengeBtns {
                    button.isEnabled = true
                }
            case .fail: break
            }
        }
        profileAlertController.addAction(promptAction)
        present(profileAlertController, animated: true, completion: nil)
    }
    
    func emojiDecode(emojiString: String) -> String? {
        if  let data = emojiString.data(using: .utf8), let emoji = String(data: data, encoding: .nonLossyASCII) {
            return emoji
        }
        return "can not decode the emoji"
    }
    
    func emojiEncode(emoji: String) -> String {
        if  let data = emoji.data(using: .nonLossyASCII, allowLossyConversion: true), let emojiString = String(data: data, encoding: .utf8) {
            return emojiString
        }
        return "can not encode the emoji"
    }
}

extension ProfileVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case profileNickNameTF:
            profileData?.nickname = textField.text ?? ""
        case profileDescribeTF:
            profileData?.describe = textField.text ?? ""
        case profileEmojiTF:
            let newEmoji = textField.text ?? ""
            profileData?.emoji = emojiEncode(emoji: newEmoji)
        default:
            break
        }
    }
}

extension ProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //顯示頭貼
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadProfile data: [String: Any]) {
        let loginUser = User(
            userId: data["userId"] as? String ?? "no user id",
            nickname: data["nickname"] as? String ?? "no nickname",
            describe: data["describe"] as? String ?? "no describe",
            emoji: data["emoji"] as? String ?? "no emoji",
            image: data["image"] as? String ?? "no image"
        )
        profileSetting(userData: loginUser)
    }
    
}
