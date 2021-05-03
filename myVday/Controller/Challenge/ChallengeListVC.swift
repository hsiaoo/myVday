//
//  ChallengeListVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/19.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

enum ChallengeLayoutType {
    case challengeList, newChallengeRequest
}

enum ChallengeActionType {
    case acceptChallenge, deleteChallengeRequest
}

class ChallengeListVC: UIViewController {

    @IBOutlet weak var challengeNotiBtn: UIBarButtonItem!
    @IBOutlet weak var newChallengeBtn: UIBarButtonItem!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var challengeListTableView: UITableView!
    @IBOutlet weak var noChallengeLabel: UILabel!
    
    let firebaseManager = FirebaseManager.instance
    var myChallenge = [Challenge]()
    var currentLayout: ChallengeLayoutType = .challengeList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.delegate = self
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            firebaseManager.fetchMyChallenge(ownerId: userId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            firebaseManager.fetchMyChallenge(ownerId: userId)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newChallengeSegue" {
            _ = segue.destination as? AddNewChallengeVC
        } else {
            if segue.identifier == "singleChallengeSegue" {
                if let controller = segue.destination as? SingleChallengeVC {
                    controller.singleChallengeFromList = sender as? Challenge
                }
            }
        }
    }
    
    @IBAction func checkNewChallengeBtn(_ sender: UIBarButtonItem) {
        switch currentLayout {
        case .challengeList:
            currentLayout = .newChallengeRequest
            listNameLabel.text = "挑戰邀請"
            newChallengeBtn.isEnabled = false
            newChallengeBtn.image = nil
            challengeNotiBtn.image = UIImage(systemName: "flame.fill")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                firebaseManager.fetchProfileSubCollection(userId: userId, dataType: .challengeRequest)
            }
        case .newChallengeRequest:
            currentLayout = .challengeList
            listNameLabel.text = "挑戰"
            newChallengeBtn.isEnabled = true
            newChallengeBtn.image = UIImage(systemName: "plus.circle")
            challengeNotiBtn.image = UIImage(systemName: "bell")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                firebaseManager.fetchMyChallenge(ownerId: userId)
            }
        }
    }
    
    @IBAction func addNewChallengeBtn(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newChallengeSegue", sender: nil)
    }
    
    func challengeRequestAlert(
        actionType: ChallengeActionType,
        title: String,
        message: String,
        acceptedChallenge: Challenge,
        targetChallenge: Challenge,
        userId: String,
        indexPath: IndexPath) {
        let requestAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        switch actionType {
            
        case .acceptChallenge:
            //接受挑戰邀請
            let confirmAction = UIAlertAction(title: "確定", style: .default) { _ in
                //新增owner為登入者的挑戰，這裡的ownerId是登入者的userId
                self.firebaseManager.addChallenge(newChallenge: acceptedChallenge, friendId: "", ownerId: acceptedChallenge.ownerId) {
                    //移除畫面上已被被接受挑戰的那一列
                    self.myChallenge.remove(at: indexPath.row)
                    self.challengeListTableView.beginUpdates()
                    self.challengeListTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.challengeListTableView.endUpdates()
                }
                //將已接受的挑戰從firestore邀請列表中移除
                self.firebaseManager.deleteRequest(user: userId, dataType: .challengeRequest, requestId: targetChallenge.challengeId)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            requestAlertController.addAction(confirmAction)
            requestAlertController.addAction(cancelAction)
            
        case .deleteChallengeRequest:
            let confirmAction = UIAlertAction(title: "確定", style: .default) { _ in
                //拒絕挑戰邀請
                self.myChallenge.remove(at: indexPath.row)
                self.challengeListTableView.beginUpdates()
                self.challengeListTableView.deleteRows(at: [indexPath], with: .automatic)
                self.challengeListTableView.endUpdates()
                //將被拒絕的挑戰從firestore邀請列表中移除
                self.firebaseManager.deleteRequest(user: userId, dataType: .challengeRequest, requestId: targetChallenge.challengeId)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            requestAlertController.addAction(confirmAction)
            requestAlertController.addAction(cancelAction)
        }
        present(requestAlertController, animated: true, completion: nil)
    }

}

extension ChallengeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myChallenge.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let challengeCell = tableView.dequeueReusableCell(
            withIdentifier: ChallengeListTableViewCell.identifier,
            for: indexPath) as? ChallengeListTableViewCell {
            
            switch currentLayout {
            case .challengeList:
                if myChallenge[indexPath.row].daysCompleted == myChallenge[indexPath.row].days {
                    challengeCell.challengeImageView.image = UIImage(named: "success")
                } else {
                    challengeCell.challengeImageView.image = UIImage(systemName: "flame.fill")
                }
                challengeCell.challengeTitleLabel.text = myChallenge[indexPath.row].title
                challengeCell.challengeDescribeLabel.text = myChallenge[indexPath.row].describe
                challengeCell.challengeCheckmarkBtn.isHidden = true
                
                //以背景色區分單人挑戰、雙人挑戰
//                let vsId = myChallenge[indexPath.row].vsChallengeId
//                if vsId.isEmpty {
//                    friendChallengeCell.backgroundColor = UIColor(named: "myyellow")
//                } else {
//                    friendChallengeCell.backgroundColor = UIColor(named: "mypink")
//                }
                return challengeCell
            case .newChallengeRequest:
                if myChallenge.isEmpty {
                    challengeCell.challengeImageView.image = nil
                    challengeCell.challengeTitleLabel.text = "目前沒有挑戰邀請哦"
                    challengeCell.challengeDescribeLabel.text = ""
                    return challengeCell
                } else {
                    challengeCell.challengeImageView.image = UIImage(systemName: "flame.fill")
                    challengeCell.challengeTitleLabel.text = myChallenge[indexPath.row].title
                    challengeCell.challengeDescribeLabel.text =
                        "\(myChallenge[indexPath.row].ownerName)" +
                        "向你發出\(myChallenge[indexPath.row].days)天挑戰：\n" +
                    "\(myChallenge[indexPath.row].describe)"
                    challengeCell.challengeCheckmarkBtn.isHidden = false
                    challengeCell.challengeCheckmarkBtn.addTarget(self, action: #selector(acceptRequest(_:)), for: .touchUpInside)
                    return challengeCell
                }
            }
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func acceptRequest(_ sender: UIButton) {
        guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential"),
        let userNickname = UserDefaults.standard.string(forKey: "userNickname") else { return }
        let tappedPoint = sender.convert(CGPoint.zero, to: challengeListTableView)
        if let indexPath = challengeListTableView.indexPathForRow(at: tappedPoint) {
            let targetChallenge = myChallenge[indexPath.row]
            
            //為了將ownerId和ownerName改成登入者的資料，所以新建立一個常數acceptedChallenge
            let acceptedChallenge = Challenge(
                challengeId: targetChallenge.challengeId,
                ownerId: userId,
                ownerName: userNickname,
                title: targetChallenge.title,
                describe: targetChallenge.describe,
                days: targetChallenge.days,
                vsChallengeId: targetChallenge.vsChallengeId,
                updatedTime: targetChallenge.updatedTime,
                daysCompleted: targetChallenge.daysCompleted)
            
            challengeRequestAlert(
                actionType: .acceptChallenge,
                title: "👌🏼接受挑戰邀請",
                message: "接受挑戰：\(acceptedChallenge.title)",
                acceptedChallenge: acceptedChallenge,
                targetChallenge: targetChallenge,
                userId: userId,
                indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentLayout {
        case .challengeList:
            let singleChallenge = myChallenge[indexPath.row]
            performSegue(withIdentifier: "singleChallengeSegue", sender: singleChallenge)
        case .newChallengeRequest:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if currentLayout == .challengeList {
            //如果是在挑戰列表畫面，則不啟用左滑刪除功能
            return nil
        } else {
            let deleteContextItem = UIContextualAction(style: .destructive, title: "") { (_, _, completion) in
                guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") else { return }
                let targetChallenge = self.myChallenge[indexPath.row]
                
                //其實不需要acceptedChallenge...
                self.challengeRequestAlert(
                    actionType: .deleteChallengeRequest,
                    title: "💢拒絕挑戰邀請",
                    message: "拒絕挑戰：\(targetChallenge.title)",
                    acceptedChallenge: targetChallenge,
                    targetChallenge: targetChallenge,
                    userId: userId,
                    indexPath: indexPath)
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
    
}

extension ChallengeListVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadChallenge data: [QueryDocumentSnapshot]) {
        myChallenge.removeAll()
         for document in data {
             let aChallenge = Challenge(
                 challengeId: document["challengeId"] as? String ?? "no challenge id",
                 ownerId: document["ownerId"] as? String ?? "no owner id",
                 ownerName: document["ownerName"] as? String ?? "no owner name",
                 title: document["title"] as? String ?? "no title",
                 describe: document["describe"] as? String ?? "no describe",
                 days: document["days"] as? Int ?? 0,
                 vsChallengeId: document["vsChallengeId"] as? String ?? "no vsChallengeId",
                 updatedTime: document["updatedTime"] as? String ?? "no updatedTime",
                 daysCompleted: document["daysCompleted"] as? Int ?? 0)
             myChallenge.append(aChallenge)
         }
        
        if myChallenge.isEmpty {
            noChallengeLabel.isHidden = false
        } else {
            noChallengeLabel.isHidden = true
        }
        challengeListTableView.reloadData()
     }
    
    func fireManager(_ manager: FirebaseManager, didDownloadProfileDetail data: [QueryDocumentSnapshot], type: DataType) {
        if type == .challengeRequest {
            myChallenge.removeAll()
            for document in data {
                let aChallenge = Challenge(
                    challengeId: document["challengeId"] as? String ?? "no challenge id",
                    ownerId: document["ownerId"] as? String ?? "no owner",
                    ownerName: document["ownerName"] as? String ?? "no owner name",
                    title: document["title"] as? String ?? "no title",
                    describe: document["describe"] as? String ?? "no describe",
                    days: document["days"] as? Int ?? 0,
                    vsChallengeId: document["vsChallengeId"] as? String ?? "no vsChallengeId",
                    updatedTime: document["updatedTime"] as? String ?? "no updatedTime",
                    daysCompleted: document["daysCompleted"] as? Int ?? 0)
                myChallenge.append(aChallenge)
            }
            
            if myChallenge.isEmpty {
                noChallengeLabel.isHidden = false
            } else {
                noChallengeLabel.isHidden = true
            }
            challengeListTableView.reloadData()
        } else {
            return
        }
    }
}
