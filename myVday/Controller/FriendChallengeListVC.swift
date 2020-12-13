//
//  FriendChallengeListVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/9.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

enum LayoutType {
    case friendList, challengeList, addNewFriend, addNewChallenge
}

class FriendChallengeListVC: UIViewController {
    
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var newFriendSearchBar: UISearchBar!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendChallengeTableView: UITableView!
    
    let fireManager = FirebaseManager()
//    var isFriendList = false
    var currentLayoutType: LayoutType = .challengeList
    var friends = [User]()
    var myChallenge = [Challenge]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        listSetting()
    }
    
    @IBAction func tappedNotiBtn(_ sender: Any) {
    }
    
    @IBAction func addFriendOrChallengeBtn(_ sender: Any) {
        if currentLayoutType == .friendList {
            tableViewTopConstraint.constant = 86
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: .allowAnimatedContent,
                animations: {
                    self.friendChallengeTableView.frame = CGRect(x: 0, y: 167, width: UIScreen.main.bounds.width, height: 675)
            },
                completion: nil)
            newFriendSearchBar.isHidden = false
        } else if currentLayoutType == .challengeList {
            performSegue(withIdentifier: "newChallengeSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "singleChallengeSegue" {
            if let controller = segue.destination as? SingleChallengeVC {
                controller.singleChallengeFromList = sender as? Challenge
            }
        } else {
            if segue.identifier == "newChallengeSegue" {
                if let controller = segue.destination as? AddNewChallengeVC {
                    controller.didAddedChallenge = {
                        self.listSetting()
                    }
                }
            }
        }
    }
    
//    func listSetting() {
//        if isFriendList == true {
//            listNameLabel.text = "朋友們"
//            fireManager.fetchProfileSubCollection(userId: "Austin", dataType: .friends)
//        } else {
//            listNameLabel.text = "挑戰們"
//            fireManager.fetchMyChallenge(ower: "Austin")
//        }
//    }
    
    func listSetting() {
        myChallenge.removeAll()
        switch currentLayoutType {
        case .friendList:
            listNameLabel.text = "好友"
            fireManager.fetchProfileSubCollection(userId: "Austin", dataType: .friends)
        case .challengeList:
            listNameLabel.text = "挑戰"
            fireManager.fetchMyChallenge(ower: "Austin")
        case .addNewFriend: break
        case .addNewChallenge: break
        }
    }
    
}

extension FriendChallengeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFriendList == true {
//            return friends.count
//        } else {
//            return myChallenge.count
//        }
        switch currentLayoutType {
        case .friendList: return friends.count
        case .challengeList: return myChallenge.count
        case .addNewChallenge, .addNewFriend: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let friendChallengeCell = tableView.dequeueReusableCell(
            withIdentifier: FriendChallengeListTableViewCell.identifier,
            for: indexPath) as? FriendChallengeListTableViewCell {
            
            switch currentLayoutType {
            case .friendList:
                friendChallengeCell.listTitleLabel.text = "\(friends[indexPath.row].nickname)" + " " + "\(friends[indexPath.row].emoji)"
                friendChallengeCell.listDescribeLabel.text = friends[indexPath.row].describe
                return friendChallengeCell
            case .challengeList:
                friendChallengeCell.listTitleLabel.text = myChallenge[indexPath.row].title
                friendChallengeCell.listDescribeLabel.text = myChallenge[indexPath.row].describe
                
                let vsId = myChallenge[indexPath.row].vsChallengeId
                if vsId.isEmpty {
                    friendChallengeCell.backgroundColor = UIColor(named: "myyellow")
                } else {
                    friendChallengeCell.backgroundColor = UIColor(named: "mypink")
                }
                return friendChallengeCell
            case .addNewChallenge, .addNewFriend: break
            }
            //            if isFriendList == true {
            //                friendChallengeCell.listTitleLabel.text = "\(friends[indexPath.row].nickname)" + " " + "\(friends[indexPath.row].emoji)"
            //                friendChallengeCell.listDescribeLabel.text = friends[indexPath.row].describe
            //            } else {
            //                friendChallengeCell.listTitleLabel.text = myChallenge[indexPath.row].title
            //                friendChallengeCell.listDescribeLabel.text = myChallenge[indexPath.row].describe
            //
            //                let vsId = myChallenge[indexPath.row].vsChallengeId
            //                if vsId.isEmpty {
            //                    friendChallengeCell.backgroundColor = UIColor(named: "myyellow")
            //                } else {
            //                    friendChallengeCell.backgroundColor = UIColor(named: "mypink")
            //                }
            //            }
            //            return friendChallengeCell
            //        } else {
            //            return UITableViewCell()
            //        }
        }
        return UITableViewCell()
    }
        
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentLayoutType {
        case .friendList: return
        case .challengeList:
            let singleChallenge = myChallenge[indexPath.row]
            performSegue(withIdentifier: "singleChallengeSegue", sender: singleChallenge)
        case .addNewChallenge, .addNewFriend: break
        }
//        if isFriendList == true {
//            return
//        } else {
//            let singleChallenge = myChallenge[indexPath.row]
//            performSegue(withIdentifier: "singleChallengeSegue", sender: singleChallenge)
//        }
    }
    
}

extension FriendChallengeListVC: FirebaseManagerDelegate {
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
                    friends.append(aUser)
                }
                friendChallengeTableView.reloadData()
            }
        case .friendRequests:
            print("friend requests")
        case .challengeRequests:
            print("challengeRequests")
        case .comments, .menu, .owner, .challenger: break
        }
    }
    
    func fireManager(_ manager: FirebaseManager, didDownloadChallenge data: [QueryDocumentSnapshot]) {
        for document in data {
            let aChallenge = Challenge(
                challengeId: document["challengeId"] as? String ?? "no challenge id",
                owner: document["owner"] as? String ?? "no owner",
                title: document["title"] as? String ?? "no title",
                describe: document["describe"] as? String ?? "no describe",
                days: document["days"] as? Int ?? 0,
                vsChallengeId: document["vsChallengeId"] as? String ?? "no vsChallengeId",
                updatedTime: document["updatedTime"] as? String ?? "no updatedTime")
            myChallenge.append(aChallenge)
        }
        friendChallengeTableView.reloadData()
    }
}
