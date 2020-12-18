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
    
    @IBOutlet weak var profileNormalView: UIView!
    @IBOutlet weak var profleEditingView: UIView!
    @IBOutlet weak var editSaveBarBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBarBtn: UIBarButtonItem!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileDescribeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileEmojiLabel: UILabel!
    @IBOutlet weak var friendBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    
    @IBOutlet weak var editingImageView: UIButton!
    @IBOutlet weak var editingNameTF: UITextField!
    @IBOutlet weak var editingDescribeTF: UITextField!
    @IBOutlet weak var editingEmojiTF: UITextField!
    
    let fireManager = FirebaseManager()
    var userData: User?
    
    var isEditingProfile = false {
        didSet {
            if isEditingProfile == true {
                profleEditingView.isHidden = false
                profileNormalView.isHidden = true
                editSaveBarBtn.image = UIImage(systemName: "checkmark")
                cancelBarBtn.image = UIImage(systemName: "arrowshape.turn.up.left")
                friendBtn.isEnabled = false
                challengeBtn.isEnabled = false
            } else {
                profleEditingView.isHidden = true
                profileNormalView.isHidden = false
                editSaveBarBtn.image = UIImage(systemName: "pencil")
                cancelBarBtn.image = nil
                friendBtn.isEnabled = true
                challengeBtn.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        fireManager.fetchProfileData(userId: "Austin")
    }
    
    @IBAction func editProfileBtn(_ sender: Any) {
        isEditingProfile = !isEditingProfile
        if isEditingProfile == true {
            editingNameTF.placeholder = userData?.nickname
            editingDescribeTF.placeholder = userData?.describe
            if let userData = userData, let emoji =  emojiDecode(emojiString: userData.emoji) {
                editingEmojiTF.placeholder = emoji
            }
        } else {
            var newNickname: String?
            var newDescribe: String?
            var newEmoji: String?
            
            guard let nickname = editingNameTF.text,
                let describe = editingDescribeTF.text,
                let emoji = editingEmojiTF.text else { return }
            
            let emojiString = emojiEncode(emoji: emoji)
            
            if nickname.isEmpty {
                newNickname = userData?.nickname ?? ""
            } else {
                newNickname = nickname
            }
            
            if describe.isEmpty {
                newDescribe = userData?.describe ?? ""
            } else {
                newDescribe = describe
            }
            
            if emojiString.isEmpty {
                newEmoji = userData?.emoji ?? ""
            } else {
                newEmoji = emojiString
            }
            
            if let okNickname = newNickname, let okDescribe = newDescribe, let okEmoji = newEmoji {
                fireManager.updateProfile(userId: "Austin", newNickname: okNickname, newDescribe: okDescribe, newEmoji: okEmoji)
            }
            fireManager.fetchProfileData(userId: "Austin")
            editingNameTF.text = ""
            editingDescribeTF.text = ""
            editingEmojiTF.text = ""
            editingNameTF.resignFirstResponder()
            editingDescribeTF.resignFirstResponder()
            editingEmojiTF.resignFirstResponder()
        }
    }
    
    @IBAction func cancelEditProfileBtn(_ sender: Any) {
        isEditingProfile = !isEditingProfile
        editingNameTF.text = ""
        editingDescribeTF.text = ""
        editingEmojiTF.text = ""
        editingNameTF.resignFirstResponder()
        editingDescribeTF.resignFirstResponder()
        editingEmojiTF.resignFirstResponder()
    }
    
    @IBAction func friendBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "friendSegue", sender: nil)
    }
    
    @IBAction func challengeBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "challengeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendSegue" {
            if let controller = segue.destination as? FriendChallengeListVC {
//                controller.isFriendList = true
                controller.currentLayoutType = .friendList
            }
        } else {
            if let controller = segue.destination as? FriendChallengeListVC {
//                controller.isFriendList = false
                controller.currentLayoutType = .challengeList
            }
        }
    }
    
    func profileSetting(userData: User) {
        profileNameLabel.text = userData.nickname
        profileDescribeLabel.text = userData.describe
        profileEmojiLabel.text = emojiDecode(emojiString: userData.emoji)
//        profileImageView.image =
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

extension ProfileVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadProfile data: [String: Any]) {
        userData = User(
            userId: data["userId"] as? String ?? "no user id",
            nickname: data["nickname"] as? String ?? "no nickname",
            describe: data["describe"] as? String ?? "no describe",
            emoji: data["emoji"] as? String ?? "no emoji",
            image: data["image"] as? String ?? "no image")
        if let okUserData = userData {
            self.profileSetting(userData: okUserData)
        }
    }
    
}
