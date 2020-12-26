//
//  AddNewChallengeVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/13.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

enum ChallengeStatus {
    case success, fail
}

class AddNewChallengeVC: UIViewController {
    
    @IBOutlet weak var challengeTitleTF: UITextField!
    @IBOutlet weak var challengeDescribeTF: UITextField!
    @IBOutlet weak var challengeDaysTF: UITextField!
    @IBOutlet weak var challengeFriendTF: UITextField!
    
    let fireManager = FirebaseManager()
    var friendTableView = UITableView()
    var myFriends = [User]()
    var vsFriendId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        friendTableViewSetting()
        challengeFriendTF.inputView = friendTableView
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            //fetch user's friends for friendTableView
            fireManager.fetchSubCollection(mainCollection: .user, mainDocId: userId, sub: .friends)
        }
    }
    
    @IBAction func tappedDoneBtn(_ sender: UIBarButtonItem) {
        let title = challengeTitleTF.text ?? ""
        let describe = challengeDescribeTF.text ?? ""
        let daysString = challengeDaysTF.text ?? ""
        let friendId = vsFriendId ?? ""
        
        guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential"),
            let userNickname = UserDefaults.standard.string(forKey: "userNickname") else { return }
        
        if title.isEmpty || describe.isEmpty || daysString.isEmpty {
            newChallengeAlert(status: .fail, title: "😶", message: "請填好挑戰資料")
        } else {
            let daysInt = Int(daysString) ?? 0
            if daysInt == 0 {
                newChallengeAlert(status: .fail, title: "😶", message: "請填好挑戰天數")
            } else {
                let newChallenge = Challenge(
                    challengeId: "",
                    ownerId: userId,
                    ownerName: userNickname,
                    title: title,
                    describe: describe,
                    days: daysInt,
                    vsChallengeId: "",
                    updatedTime: "",
                    daysCompleted: 0)
                fireManager.addChallenge(newChallenge: newChallenge, friendId: friendId, ownerId: userId) {
                    self.newChallengeAlert(status: .success, title: "🔥GO GO GO", message: "成功發起一項挑戰！")
                }
            }
        }
    }
    
    func newChallengeAlert(status: ChallengeStatus, title: String, message: String) {
        let newChallengeAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let promptAction = UIAlertAction(title: "確定", style: .default) { _ in
            switch status {
            case .success: self.navigationController?.popViewController(animated: true)
            case .fail: break
            }
        }
        newChallengeAlertController.addAction(promptAction)
        present(newChallengeAlertController, animated: true, completion: nil)
    }
    
}

extension AddNewChallengeVC: UITextFieldDelegate {
    //按下鍵盤next跳往下一個text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextRseponder = textField.superview?.viewWithTag(nextTag) {
            nextRseponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension AddNewChallengeVC: UITableViewDelegate, UITableViewDataSource {
    func friendTableViewSetting() {
        //this is a tableView for input view of textField
        friendTableView.delegate = self
        friendTableView.dataSource = self
        friendTableView.separatorStyle = .none
        friendTableView.register(ChallengeWithFriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
        friendTableView.frame = CGRect(x: 0, y: challengeFriendTF.frame.maxY, width: UIScreen.main.bounds.width, height: 250)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myFriends.isEmpty {
            return 1
        } else {
            return myFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let friendCell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? ChallengeWithFriendTableViewCell {
            friendCell.selectionStyle = .none
            if myFriends.isEmpty {
                friendCell.friendImageView.layer.backgroundColor = UIColor.clear.cgColor
                friendCell.friendNameLabel.text = "目前還沒有好友哦"
                return friendCell
            } else {
                friendCell.friendNameLabel.text = myFriends[indexPath.row].nickname
                
                if myFriends[indexPath.row].image.isEmpty {
                    friendCell.friendImageView.image = UIImage(named: "profile128")
                    return friendCell
                } else {
                    
                    if let imageUrl = URL(string: myFriends[indexPath.row].image) {
                        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                            if let err = error {
                                print("Error download image: \(err)")
                            } else {
                                if let okData = data {
                                    DispatchQueue.main.async {
                                        friendCell.friendImageView.image = UIImage(data: okData)
                                    }
                                }
                            }
                        }.resume()
                    }
                    
                    return friendCell
                }
                
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vsFriendId = myFriends[indexPath.row].userId
        challengeFriendTF.text = myFriends[indexPath.row].nickname
    }
    
}

extension AddNewChallengeVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, fetchSubCollection docArray: [QueryDocumentSnapshot], sub: SubCollection) {
        if sub == .friends {
            for document in docArray {
                if  let emojiString = document["emoji"] as? String,
                    let emoji = ProfileVC().emojiDecode(emojiString: emojiString) {
                    let aUser = User(
                        userId: document["userId"] as? String ?? "no user id",
                        nickname: document["nickname"] as? String ?? "no nickname",
                        describe: document["describe"] as? String ?? "no describe",
                        emoji: emoji,
                        image: document["image"] as? String ?? "no image")
                    myFriends.append(aUser)
                }
            }
        }
    }
}
