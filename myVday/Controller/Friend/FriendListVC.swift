//
//  FriendListVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/9.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

enum FriendLayoutType {
    case friendList, newFriendRequest
}

class FriendListVC: UIViewController {
    
    @IBOutlet weak var friendNotiBtn: UIBarButtonItem!
    @IBOutlet weak var newFriendBtn: UIBarButtonItem!
    @IBOutlet weak var listIconImageView: UIImageView!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var friendListTableView: UITableView!
    
    let fireManager = FirebaseManager()
    var userData: User?
    var myFriends = [User]()
    var currentLayoutType: FriendLayoutType = .friendList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fireManager.delegate = self
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            //fetch all my friends' data
            fireManager.fetchSubCollection(mainCollection: .user, mainDocId: userId, sub: .friends)
        }
    }
    
    @IBAction func checkNewFriendBtn(_ sender: UIBarButtonItem) {
        switch currentLayoutType {
        case .friendList:
            currentLayoutType = .newFriendRequest
            listNameLabel.text = "好友邀請"
            newFriendBtn.isEnabled = false
            newFriendBtn.image = nil
            friendNotiBtn.image = UIImage(systemName: "person.2.fill")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                //抓取好友邀請清單
                fireManager.fetchSubCollection(mainCollection: .user, mainDocId: userId, sub: .friendRequest)
            }
        case .newFriendRequest:
            currentLayoutType = .friendList
            listNameLabel.text = "好友"
            newFriendBtn.isEnabled = true
            newFriendBtn.image = UIImage(systemName: "plus.circle")
            friendNotiBtn.image = UIImage(systemName: "bell")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                //抓取好友清單
                fireManager.fetchSubCollection(mainCollection: .user, mainDocId: userId, sub: .friends)
            }
        }
    }
    
    @IBAction func addNewFriendBtn(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newFriendSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newFriendSegue" {
            if let controller = segue.destination as? AddNewFriendVC {
                controller.alreadyFriend = myFriends
            }
        }
    }
    
}

extension FriendListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let friendChallengeCell = tableView.dequeueReusableCell(
            withIdentifier: FriendChallengeListTableViewCell.identifier,
            for: indexPath) as? FriendChallengeListTableViewCell {
            
            switch currentLayoutType {
            case .friendList:
                friendChallengeCell.listTitleLabel.text = "\(myFriends[indexPath.row].nickname)" + " " + "\(myFriends[indexPath.row].emoji)"
                friendChallengeCell.listDescribeLabel.text = myFriends[indexPath.row].describe
                friendChallengeCell.confirmBtn.isHidden = true
                return friendChallengeCell
            case .newFriendRequest:
                friendChallengeCell.listTitleLabel.text = "\(myFriends[indexPath.row].nickname)"
                friendChallengeCell.listDescribeLabel.text =
                    "向你發出好友邀請\n" +
                "\(myFriends[indexPath.row].describe)"
                friendChallengeCell.confirmBtn.isHidden = false
                friendChallengeCell.confirmBtn.addTarget(self, action: #selector(acceptRequest(_:)), for: .touchUpInside)
                return friendChallengeCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if currentLayoutType == .friendList {
            //如果是在好友列表畫面，則不啟用左滑刪除功能
            return nil
        } else {
            let deleteContextItem = UIContextualAction(style: .destructive, title: "") { (_, view, completion) in
                guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") else { return }
                let targetUser = self.myFriends[indexPath.row]
                //將被拒絕的人從畫面上移除
                self.myFriends.remove(at: indexPath.row)
                self.friendListTableView.beginUpdates()
                self.friendListTableView.deleteRows(at: [indexPath], with: .automatic)
                self.friendListTableView.endUpdates()
                //將被拒絕的人從firestore好友邀請列表中移除
                self.fireManager.deleteSubCollectionDoc(mainCollection: .user, mainDocId: userId, sub: .friendRequest, subDocId: targetUser.userId)
                
                completion(true)
            }
            deleteContextItem.image = UIImage(systemName: "trash")
            let swipeAction = UISwipeActionsConfiguration(actions: [deleteContextItem])
            return swipeAction
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //接受好友邀請
    @objc func acceptRequest(_ sender: UIButton) {
        guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") else { return }
        let tappedPoint = sender.convert(CGPoint.zero, to: friendListTableView)
        if let indexPath = friendListTableView.indexPathForRow(at: tappedPoint) {
            let targetUser = myFriends[indexPath.row]
            fireManager.fetchMainCollectionDoc(mainCollection: .user, docId: userId)
            guard let personalUserData = userData else { return }
            //將自己加進別人的朋友列表
            fireManager.addNewFriend(friendsOfUserId: targetUser.userId, newFriend: personalUserData)
            //將別人加進自己的朋友列表
            fireManager.addNewFriend(friendsOfUserId: userId, newFriend: targetUser)
            //將已接受的好友從firestore邀請列表中移除
            fireManager.deleteSubCollectionDoc(mainCollection: .user, mainDocId: userId, sub: .friendRequest, subDocId: targetUser.userId)
            //將已接受的好友從畫面中移除
            myFriends.remove(at: indexPath.row)
            friendListTableView.beginUpdates()
            friendListTableView.deleteRows(at: [indexPath], with: .automatic)
            friendListTableView.endUpdates()
        }
    }
    
}

extension FriendListVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, fetchDoc: [String: Any]) {
        //fetch personal data
        userData = User(
            userId: fetchDoc["userId"] as? String ?? "no user id",
            nickname: fetchDoc["nickname"] as? String ?? "no nickname",
            describe: fetchDoc["describe"] as? String ?? "no describe",
            emoji: fetchDoc["emoji"] as? String ?? "no emoji",
            image: fetchDoc["image"] as? String ?? "no image")
    }
    
    func fireManager(_ manager: FirebaseManager, fetchSubCollection docArray: [QueryDocumentSnapshot], sub: SubCollection) {
        myFriends.removeAll()
        if sub == .friends {
            for document in docArray {
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
                friendListTableView.reloadData()
            }
        } else if sub == .friendRequest {
            for document in docArray {
                let aUser = User(
                    userId: document["userId"] as? String ?? "no user id",
                    nickname: document["nickname"] as? String ?? "no nickname",
                    describe: document["describe"] as? String ?? "no describe",
                    emoji: document["emoji"] as? String ?? "no emoji",
                    image: document["image"] as? String ?? "no image")
                myFriends.append(aUser)
            }
            friendListTableView.reloadData()
        } else {
            return
        }
    }
}
