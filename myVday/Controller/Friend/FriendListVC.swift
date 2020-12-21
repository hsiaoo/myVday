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
            fireManager.fetchProfileSubCollection(userId: userId, dataType: .friends)
        }
    }
    
    @IBAction func checkNewFriendBtn(_ sender: UIBarButtonItem) {
        switch currentLayoutType {
        case .friendList:
            currentLayoutType = .newFriendRequest
            listNameLabel.text = "好友邀請"
            newFriendBtn.image = nil
            friendNotiBtn.image = UIImage(systemName: "person.2.fill")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                fireManager.fetchProfileSubCollection(userId: userId, dataType: .friendRequest)
            }
        case .newFriendRequest:
            currentLayoutType = .friendList
            listNameLabel.text = "好友"
            newFriendBtn.image = UIImage(systemName: "plus.circle")
            friendNotiBtn.image = UIImage(systemName: "bell")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                fireManager.fetchProfileSubCollection(userId: userId, dataType: .friends)
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
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") else { return }
        //拒絕好友邀請
        let targetUser = myFriends[indexPath.row]
        if editingStyle == .delete {
            myFriends.remove(at: indexPath.row)
            friendListTableView.beginUpdates()
            friendListTableView.deleteRows(at: [indexPath], with: .automatic)
            friendListTableView.endUpdates()
            fireManager.deleteRequest(user: userId, dataType: .friendRequest, requestId: targetUser.userId)
        }
    }
    
    @objc func acceptRequest(_ sender: UIButton) {
        guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") else { return }
        let tappedPoint = sender.convert(CGPoint.zero, to: friendListTableView)
        if let indexPath = friendListTableView.indexPathForRow(at: tappedPoint) {
             //接受好友邀請
             let targetUser = myFriends[indexPath.row]
             
             fireManager.fetchProfileData(userId: userId)
             guard let personalUserData = userData else { return }
             fireManager.addNewFriend(friendsOfUserId: targetUser.userId, newFriend: personalUserData)
             fireManager.addNewFriend(friendsOfUserId: userId, newFriend: targetUser)
             fireManager.deleteRequest(user: userId, dataType: .friendRequest, requestId: targetUser.userId)
            
             myFriends.remove(at: indexPath.row)
             friendListTableView.beginUpdates()
             friendListTableView.deleteRows(at: [indexPath], with: .automatic)
             friendListTableView.endUpdates()
        }
    }
    
}

extension FriendListVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadProfileDetail data: [QueryDocumentSnapshot], type: DataType) {
        switch type {
        case .friends:
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
                friendListTableView.reloadData()
            }
            
        case .friendRequest:
            myFriends.removeAll()
            for document in data {
                let aUser = User(
                    userId: document["userId"] as? String ?? "no user id",
                    nickname: document["nickname"] as? String ?? "no nickname",
                    describe: document["describe"] as? String ?? "no describe",
                    emoji: document["emoji"] as? String ?? "no emoji",
                    image: document["image"] as? String ?? "no image")
                myFriends.append(aUser)
            }
            friendListTableView.reloadData()
        case .comments, .menu, .challengeRequest, .owner, .challenger: break
        }
    }
    
    func fireManager(_ manager: FirebaseManager, didDownloadProfile data: [String: Any]) {
        userData = User(
            userId: data["userId"] as? String ?? "no user id",
            nickname: data["nickname"] as? String ?? "no nickname",
            describe: data["describe"] as? String ?? "no describe",
            emoji: data["emoji"] as? String ?? "no emoji",
            image: data["image"] as? String ?? "no image")
    }
}
