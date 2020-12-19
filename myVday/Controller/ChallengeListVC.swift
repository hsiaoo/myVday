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

class ChallengeListVC: UIViewController {

    @IBOutlet weak var challengeNotiBtn: UIBarButtonItem!
    @IBOutlet weak var newChallengeBtn: UIBarButtonItem!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var challengeListTableView: UITableView!
    
    let fireManager = FirebaseManager()
    var myChallenge = [Challenge]()
    var currentLayout: ChallengeLayoutType = .challengeList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            fireManager.fetchMyChallenge(ower: userId)
        }
    }
    
    @IBAction func checkNewChallengeBtn(_ sender: UIBarButtonItem) {
        switch currentLayout {
        case .challengeList:
            currentLayout = .newChallengeRequest
            listNameLabel.text = "挑戰邀請"
            newChallengeBtn.image = nil
            challengeNotiBtn.image = UIImage(systemName: "flame.fill")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                fireManager.fetchProfileSubCollection(userId: userId, dataType: .challengeRequest)
            }
        case .newChallengeRequest:
            currentLayout = .challengeList
            listNameLabel.text = "挑戰"
            newChallengeBtn.image = UIImage(systemName: "plus.circle")
            challengeNotiBtn.image = UIImage(systemName: "bell")
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                fireManager.fetchMyChallenge(ower: userId)
            }
        }
    }
    
    @IBAction func addNewChallengeBtn(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newChallengeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newChallengeSegue" {
            if let controller = segue.destination as? AddNewChallengeVC {
                controller.didAddedChallenge = {
                    if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                        self.fireManager.fetchMyChallenge(ower: userId)
                    }
                }
            }
        } else {
            if segue.identifier == "singleChallengeSegue" {
                if let controller = segue.destination as? SingleChallengeVC {
                    controller.singleChallengeFromList = sender as? Challenge
                }
            }
        }
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
                        "\(myChallenge[indexPath.row].owner)" +
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
        guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") else { return }
        let tappedPoint = sender.convert(CGPoint.zero, to: challengeListTableView)
        if let indexPath = challengeListTableView.indexPathForRow(at: tappedPoint) {
            //接受挑戰邀請
            let targetChallenge = myChallenge[indexPath.row]
            let acceptedChallenge = Challenge(
                challengeId: targetChallenge.challengeId,
                owner: userId,
                title: targetChallenge.title,
                describe: targetChallenge.describe,
                days: targetChallenge.days,
                vsChallengeId: targetChallenge.vsChallengeId,
                updatedTime: targetChallenge.updatedTime,
                daysCompleted: targetChallenge.daysCompleted)
            fireManager.addChallenge(newChallenge: acceptedChallenge, friend: "")
            fireManager.deleteRequest(user: userId, dataType: .challengeRequest, requestId: targetChallenge.challengeId)
            
            //移除畫面上已被被接受挑戰的那一列
            myChallenge.remove(at: indexPath.row)
            challengeListTableView.beginUpdates()
            challengeListTableView.deleteRows(at: [indexPath], with: .automatic)
            challengeListTableView.endUpdates()
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") else { return }
        //拒絕挑戰邀請
        let targetChallenge = myChallenge[indexPath.row]
        if editingStyle == .delete {
            myChallenge.remove(at: indexPath.row)
            challengeListTableView.beginUpdates()
            challengeListTableView.deleteRows(at: [indexPath], with: .automatic)
            challengeListTableView.endUpdates()
            fireManager.deleteRequest(user: userId, dataType: .challengeRequest, requestId: targetChallenge.challengeId)
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
         challengeListTableView.reloadData()
     }
    
    func fireManager(_ manager: FirebaseManager, didDownloadProfileDetail data: [QueryDocumentSnapshot], type: DataType) {
        if type == .challengeRequest {
            myChallenge.removeAll()
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
            challengeListTableView.reloadData()
        } else {
            return
        }
    }
}
