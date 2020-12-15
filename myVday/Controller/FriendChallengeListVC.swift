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
    case friendList, challengeList, newFriendRequest, newChallengeRequest
}

class FriendChallengeListVC: UIViewController {
    
    @IBOutlet weak var listIconImageView: UIImageView!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var newFriendChallengeBtn: UIButton!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var newFriendSearchBar: UISearchBar!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendChallengeTableView: UITableView!
    
    let fireManager = FirebaseManager()
    var myFriends = [User]()
    var myChallenge = [Challenge]()
    var isViewDidLoad = false
    var currentLayoutType: LayoutType = .challengeList {
        didSet {
            if isViewDidLoad == false {
                return
            } else {
                listSetting()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        listSetting()
    }
    
    @IBAction func tappedNotiBtn(_ sender: Any) {
        switch currentLayoutType {
        case .friendList:
            currentLayoutType = .newFriendRequest
            notificationBtn.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        case .challengeList:
            currentLayoutType = .newChallengeRequest
            notificationBtn.setImage(UIImage(systemName: "flame.fill"), for: .normal)
        case .newFriendRequest:
            currentLayoutType = .friendList
            notificationBtn.setImage(UIImage(systemName: "bell"), for: .normal)
        case .newChallengeRequest:
            currentLayoutType = .challengeList
            notificationBtn.setImage(UIImage(systemName: "bell"), for: .normal)
        }
    }
    
    @IBAction func addFriendOrChallengeBtn(_ sender: Any) {
        if currentLayoutType == .friendList {
            tableViewTopConstraint.constant = 56
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: .allowAnimatedContent,
                animations: {
                    self.friendChallengeTableView.frame = CGRect(x: 0, y: 115, width: UIScreen.main.bounds.width, height: 0)
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
    
    func listSetting() {
        isViewDidLoad = true
        myFriends.removeAll()
        myChallenge.removeAll()
        switch currentLayoutType {
        case .friendList:
            listIconImageView.image = UIImage(systemName: "person.2.fill")
            listNameLabel.text = "好友"
            newFriendChallengeBtn.isHidden = false
            fireManager.fetchProfileSubCollection(userId: "Austin", dataType: .friends)
        case .challengeList:
            listIconImageView.image = UIImage(systemName: "flame.fill")
            listNameLabel.text = "挑戰"
            newFriendChallengeBtn.isHidden = false
            fireManager.fetchMyChallenge(ower: "Austin")
        case .newFriendRequest:
            listIconImageView.image = UIImage(systemName: "person.2.fill")
            listNameLabel.text = "好友邀請"
            newFriendChallengeBtn.isHidden = true
            fireManager.fetchProfileSubCollection(userId: "Austin", dataType: .friendRequest)
        case .newChallengeRequest:
            listIconImageView.image = UIImage(systemName: "flame.fill")
            listNameLabel.text = "挑戰邀請"
            newFriendChallengeBtn.isHidden = true
            fireManager.fetchProfileSubCollection(userId: "Austin", dataType: .challengeRequest)
        }
    }
    
}

extension FriendChallengeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentLayoutType {
        case .friendList: return myFriends.count
        case .challengeList, .newChallengeRequest: return myChallenge.count
        case .newFriendRequest: return 1
        }
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
            case .challengeList:
                if myChallenge[indexPath.row].daysCompleted == myChallenge[indexPath.row].days {
                    friendChallengeCell.friendChallengeImageView.image = UIImage(named: "success")
                } else {
                    friendChallengeCell.friendChallengeImageView.image = UIImage(systemName: "flame.fill")
                }
                
                friendChallengeCell.listTitleLabel.text = myChallenge[indexPath.row].title
                friendChallengeCell.listDescribeLabel.text = myChallenge[indexPath.row].describe
                friendChallengeCell.confirmBtn.isHidden = true
                
//                let vsId = myChallenge[indexPath.row].vsChallengeId
//                if vsId.isEmpty {
//                    friendChallengeCell.backgroundColor = UIColor(named: "myyellow")
//                } else {
//                    friendChallengeCell.backgroundColor = UIColor(named: "mypink")
//                }
                return friendChallengeCell
            case .newChallengeRequest:
                if myChallenge.isEmpty {
                    friendChallengeCell.friendChallengeImageView.image = nil
                    friendChallengeCell.listTitleLabel.text = "目前沒有挑戰邀請哦"
                    friendChallengeCell.listDescribeLabel.text = ""
                    return friendChallengeCell
                } else {
                    friendChallengeCell.friendChallengeImageView.image = UIImage(systemName: "flame.fill")
                    friendChallengeCell.listTitleLabel.text = myChallenge[indexPath.row].title
                    friendChallengeCell.listDescribeLabel.text =
                        "\(myChallenge[indexPath.row].owner)" +
                        "向你發出\(myChallenge[indexPath.row].days)天挑戰：\n" +
                    "\(myChallenge[indexPath.row].describe)"
                    friendChallengeCell.confirmBtn.isHidden = false
                    friendChallengeCell.confirmBtn.addTarget(self, action: #selector(acceptRequest(_:)), for: .touchUpInside)
                    return friendChallengeCell
                }
            case .newFriendRequest:
                friendChallengeCell.listTitleLabel.text = "\(myFriends[indexPath.row].nickname)" + " " + "\(myFriends[indexPath.row].emoji)"
                friendChallengeCell.listDescribeLabel.text =
                    "\(myFriends[indexPath.row].nickname)向你發出好友邀請\n" +
                "\(myFriends[indexPath.row].describe)"
                friendChallengeCell.confirmBtn.isHidden = false
                return friendChallengeCell
            }
        }
        return UITableViewCell()
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentLayoutType {
        case .friendList: return
        case .challengeList:
            let singleChallenge = myChallenge[indexPath.row]
            performSegue(withIdentifier: "singleChallengeSegue", sender: singleChallenge)
        case .newChallengeRequest, .newFriendRequest: break
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch currentLayoutType {
        case .newChallengeRequest:
            let targetChallenge = myChallenge[indexPath.row]
            if editingStyle == .delete {
                myChallenge.remove(at: indexPath.row)
                friendChallengeTableView.beginUpdates()
                friendChallengeTableView.deleteRows(at: [indexPath], with: .automatic)
                friendChallengeTableView.endUpdates()
                fireManager.deleteRequest(user: "Austin", dataType: .challengeRequest, requestId: targetChallenge.challengeId)
            }
        case .friendList, .challengeList, .newFriendRequest: break
        }
    }
    
    @objc func acceptRequest(_ sender: UIButton) {
        let tappedPoint = sender.convert(CGPoint.zero, to: friendChallengeTableView)
        if let indexPath = friendChallengeTableView.indexPathForRow(at: tappedPoint) {
            let targetChallenge = myChallenge[indexPath.row]
            let acceptedChallenge = Challenge(
                challengeId: targetChallenge.challengeId,
                owner: "Austin",
                title: targetChallenge.title,
                describe: targetChallenge.describe,
                days: targetChallenge.days,
                vsChallengeId: targetChallenge.vsChallengeId,
                updatedTime: targetChallenge.updatedTime,
                daysCompleted: targetChallenge.daysCompleted)
            fireManager.addChallenge(newChallenge: acceptedChallenge, friend: "")
            fireManager.deleteRequest(user: "Austin", dataType: .challengeRequest, requestId: targetChallenge.challengeId)
            
            //移除畫面上已被被接受挑戰的那一列
            myChallenge.remove(at: indexPath.row)
            friendChallengeTableView.beginUpdates()
            friendChallengeTableView.deleteRows(at: [indexPath], with: .automatic)
            friendChallengeTableView.endUpdates()
        }
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
                    myFriends.append(aUser)
                }
                friendChallengeTableView.reloadData()
            }
            
        case .friendRequest:
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
                friendChallengeTableView.reloadData()
            }
            
        case .challengeRequest:
            for document in data {
                let aChallenge = Challenge(
                    challengeId: document["challengeId"] as? String ?? "no challenge id",
                    owner: document["owner"] as? String ?? "no owner",
                    title: document["title"] as? String ?? "no title",
                    describe: document["describe"] as? String ?? "no describe",
                    days: document["days"] as? Int ?? 0,
                    vsChallengeId: document["vsChallengeId"] as? String ?? "no vsChallengeId",
                    updatedTime: document["updatedTime"] as? String ?? "no updatedTime",
                    daysCompleted: document["daysCompleted"] as? Int ?? 0)
                myChallenge.append(aChallenge)
            }
            friendChallengeTableView.reloadData()
            
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
                updatedTime: document["updatedTime"] as? String ?? "no updatedTime",
                daysCompleted: document["daysCompleted"] as? Int ?? 0)
            myChallenge.append(aChallenge)
        }
        friendChallengeTableView.reloadData()
    }
}
