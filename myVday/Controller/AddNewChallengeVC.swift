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
    
    let testName = ["Bella", "Nina", "Tina"]
    var myFriends = [User]()
    let fireManager = FirebaseManager()
    var didAddedChallenge: (() -> Void)!
    var friendTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 450), style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        fireManager.fetchProfileSubCollection(userId: "Austin", dataType: .friends)
        challengeTitleTF.becomeFirstResponder()
        challengeFriendTF.inputView = friendTableView
        tableViewSetting()
    }
    
    @IBAction func tappedCloseViewBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedDoneBtn(_ sender: Any) {
        guard let title = challengeTitleTF.text,
            let describe = challengeDescribeTF.text,
            let daysString = challengeDaysTF.text,
            let friendName = challengeFriendTF.text else { return }
        
        if title.isEmpty || describe.isEmpty || daysString.isEmpty {
            print("填好挑戰資料")
        } else {
            let daysInt = Int(daysString) ?? 0
            if daysInt == 0 {
                print("填好挑戰天數")
            } else {
                let newChallenge = Challenge(
                    challengeId: "",
                    owner: "Austin",
                    title: title,
                    describe: describe,
                    days: daysInt,
                    vsChallengeId: "",
                    updatedTime: "",
                    daysCompleted: 0)
                fireManager.addChallenge(newChallenge: newChallenge, friend: friendName)
                dismiss(animated: true) {
                    self.didAddedChallenge()
                }
            }
        }
    }
    
}

extension AddNewChallengeVC: UITableViewDelegate, UITableViewDataSource {
    func tableViewSetting() {
        friendTableView.delegate = self
        friendTableView.dataSource = self
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
    func fireManager(_ manager: FirebaseManager, didDownloadProfileDetail data: [QueryDocumentSnapshot], type: DataType) {
        if type == .friends {
            for document in data {
                if let emojiString = document["emoji"] as? String,
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
