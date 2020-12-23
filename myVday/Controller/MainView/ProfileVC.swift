//
//  ProfileVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/9.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBAction func tempSignOutBtn(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(nil, forKey: "appleUserIDCredential")
//        UserDefaults.standard.set(nil, forKey: "userAuthorizationCode")

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
    @IBOutlet weak var friendBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    
    let fireManager = FirebaseManager()
    var profileData: User?
    var isEditingProfile = false
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fireManager.delegate = self
        
        friendBtn.layer.cornerRadius = 10.0
        friendBtn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        friendBtn.layer.shadowOffset = CGSize(width: 0, height: 3)
        friendBtn.layer.shadowOpacity = 1.0
        friendBtn.layer.shadowRadius = 10.0
        friendBtn.layer.masksToBounds = false
        
        challengeBtn.layer.cornerRadius = 10.0
        challengeBtn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        challengeBtn.layer.shadowOffset = CGSize(width: 0, height: 3)
        challengeBtn.layer.shadowOpacity = 1.0
        challengeBtn.layer.shadowRadius = 10.0
        challengeBtn.layer.masksToBounds = false
        
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            fireManager.fetchProfileData(userId: userId)
        }
    }
    
    @IBAction func editProfileBtn(_ sender: Any) {
        isEditingProfile = !isEditingProfile
        
        if isEditingProfile == true {
            editSaveBarBtn.image = UIImage(systemName: "checkmark.circle")
            profileCameraBtn.image = UIImage(systemName: "camera")
            profileNickNameTF.isEnabled = true
            profileDescribeTF.isEnabled = true
            profileEmojiTF.isEnabled = true
            friendBtn.isEnabled = false
            challengeBtn.isEnabled = false
        } else {
            editSaveBarBtn.image = UIImage(systemName: "pencil")
            profileCameraBtn.image = nil
            profileCameraBtn.image = nil
            profileNickNameTF.isEnabled = false
            profileDescribeTF.isEnabled = false
            profileEmojiTF.isEnabled = false
            friendBtn.isEnabled = true
            challengeBtn.isEnabled = true
            
            profileNickNameTF.resignFirstResponder()
            profileDescribeTF.resignFirstResponder()
            profileEmojiTF.resignFirstResponder()
            
            if var newProfileData = profileData {
                if newProfileData.nickname.isEmpty {
                    print("請輸入暱稱")
                } else {
                    if selectedImage == nil {
                        //使用者沒有選擇頭貼，直接上傳其他資料
                        newProfileData.image = ""
                        fireManager.updateProfile(profileData: newProfileData)
                    } else {
                        //先上傳頭貼，再上傳完整的個人資料
                        if let newProfileImage = selectedImage, let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                            fireManager.uploadProfileImage(userId: userId, profileImage: newProfileImage) { (imageString) in
                                newProfileData.image = imageString
                                self.fireManager.updateProfile(profileData: newProfileData)
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
        profileData = User(
            userId: data["userId"] as? String ?? "no user id",
            nickname: data["nickname"] as? String ?? "no nickname",
            describe: data["describe"] as? String ?? "no describe",
            emoji: data["emoji"] as? String ?? "no emoji",
            image: data["image"] as? String ?? "no image"
        )
        if let okUserData = profileData {
            self.profileSetting(userData: okUserData)
            UserDefaults.standard.set(okUserData.nickname, forKey: "userNickname")
        }
    }
    
}
