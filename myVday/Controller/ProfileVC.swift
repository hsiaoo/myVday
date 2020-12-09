//
//  ProfileVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/9.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var profileNormalView: UIView!
    @IBOutlet weak var profleEditingView: UIView!
    @IBOutlet weak var editSaveBarBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBarBtn: UIBarButtonItem!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileDescribeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileEmojiLabel: UILabel!
    
    let fireManager = FirebaseManager()
    var userData: User?
    
    var isEditingProfile = false {
        didSet {
            if isEditingProfile == true {
                profleEditingView.isHidden = false
                profileNormalView.isHidden = true
                editSaveBarBtn.image = UIImage(systemName: "checkmark")
                cancelBarBtn.image = UIImage(systemName: "clear")
            } else {
                profleEditingView.isHidden = true
                profileNormalView.isHidden = false
                editSaveBarBtn.image = UIImage(systemName: "pencil")
                cancelBarBtn.image = nil
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
                controller.isFriendList = true
            }
        } else {
            if let controller = segue.destination as? FriendChallengeListVC {
                controller.isFriendList = false
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
