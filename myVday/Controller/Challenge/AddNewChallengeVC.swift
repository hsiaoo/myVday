//
//  AddNewChallengeVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/13.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AddNewChallengeVC: UIViewController {
    
    @IBOutlet weak var challengeTitleTF: UITextField!
    @IBOutlet weak var challengeDescribeTF: UITextField!
    @IBOutlet weak var challengeDaysTF: UITextField!
    @IBOutlet weak var challengeFriendTF: UITextField!
    
    let fireManager = FirebaseManager()
    var myFriends = [User]()
//    var didAddedChallenge: (() -> Void)!
    var friendTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 450), style: .plain)
    
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
        guard let title = challengeTitleTF.text,
            let describe = challengeDescribeTF.text,
            let daysString = challengeDaysTF.text,
            let friendName = challengeFriendTF.text,
            let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential"),
            let userNickname = UserDefaults.standard.string(forKey: "userNickname") else { return }
        
        if title.isEmpty || describe.isEmpty || daysString.isEmpty {
            print("填好挑戰資料")
        } else {
            let daysInt = Int(daysString) ?? 0
            if daysInt == 0 {
                print("填好挑戰天數")
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
                fireManager.addChallenge(newChallenge: newChallenge, friend: friendName, ownerId: userId)
                dismiss(animated: true, completion: nil)
//                dismiss(animated: true) {
//                    self.didAddedChallenge()
//                }
            }
        }
    }
    
}

extension AddNewChallengeVC: UITableViewDelegate, UITableViewDataSource {
    func friendTableViewSetting() {
        //this is a tableView for input view of textField
        friendTableView.delegate = self
        friendTableView.dataSource = self
        friendTableView.separatorStyle = .none
        friendTableView.register(ChallengeWithFriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
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
//                friendCell.friendImageView.image = UIImage
                friendCell.friendNameLabel.text = myFriends[indexPath.row].nickname
                return friendCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendName = myFriends[indexPath.row].nickname
        challengeFriendTF.text = friendName
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
