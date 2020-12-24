//
//  SingleChallengeVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/11.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SingleChallengeVC: UIViewController {
    
    @IBOutlet weak var challengeCollectionView: UICollectionView!
    @IBOutlet weak var challengeTitleLabel: UILabel!
    @IBOutlet weak var challengeDescribeLabel: UILabel!
    
    let fireManager = FirebaseManager()
    var singleChallengeFromList: Challenge?
    var certainDayChallenge: DaysChallenge?
    var myDaysChallenge = [DaysChallenge]()
    var challengerDaysChallenge = [DaysChallenge]()
    var challengerName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadChallenges()
    }

    func downloadChallenges() {
        if let singleChallengeFromList = singleChallengeFromList {
            challengeTitleLabel.text = singleChallengeFromList.title
            challengeDescribeLabel.text = singleChallengeFromList.describe
            fireManager.fetchChallengeDetail(challengeId: singleChallengeFromList.challengeId, dataType: .owner)
            
            if singleChallengeFromList.vsChallengeId.isEmpty {
                return
            } else {
                //抓取對方每日挑戰的紀錄
                let vsId = singleChallengeFromList.vsChallengeId
                fireManager.fetchMainCollectionDoc(mainCollection: .challenge, docId: vsId)
                fireManager.fetchChallengeDetail(challengeId: vsId, dataType: .challenger)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "todayChallengeSegue" {
            if let controller = segue.destination as? DayChallengeVC,
                let singleChallenge = singleChallengeFromList,
                let certainDayChallenge = certainDayChallenge {
                controller.theChallenge = singleChallenge
                controller.todayChallenge = certainDayChallenge
                controller.isMyChallengeData = sender as? Bool
            }
        }
    }
    
}

extension SingleChallengeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let vsId = singleChallengeFromList?.vsChallengeId, vsId.isEmpty else {
            return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myDaysChallenge.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ChallengeCollectionReusableView.identifier,
            for: indexPath) as? ChallengeCollectionReusableView {
            
            let userNickname = UserDefaults.standard.string(forKey: "userNickname") ?? ""
            let challengerNickname = challengerName ?? "challenger"
            
            if indexPath.section == 0 {
                sectionHeader.leftTitleLabel.isHidden = false
                sectionHeader.leftTitleLabel.text = userNickname
                sectionHeader.rightTitleLabel.isHidden = true
            } else {
                sectionHeader.rightTitleLabel.isHidden = false
                sectionHeader.rightTitleLabel.text = challengerNickname
                sectionHeader.leftTitleLabel.isHidden = true
            }
            return sectionHeader
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let challengeCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChallengeCollectionViewCell.identifier,
            for: indexPath) as? ChallengeCollectionViewCell {
            if indexPath.section == 0 {
                if myDaysChallenge[indexPath.row].describe.isEmpty {
                    challengeCell.challengeImageView.image = UIImage(named: "blankTasks")
                } else {
                    challengeCell.challengeImageView.image = UIImage(named: "completedTasks")
                }
            } else {
                if challengerDaysChallenge[indexPath.row].describe.isEmpty {
                    challengeCell.challengeImageView.image = UIImage(named: "blankTasks")
                } else {
                    challengeCell.challengeImageView.image = UIImage(named: "completedTasks")
                }
            }
            return challengeCell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
//            let myChallenge = myDaysChallenge[indexPath.row]
            let isMydata = true
            certainDayChallenge = myDaysChallenge[indexPath.row]
            performSegue(withIdentifier: "todayChallengeSegue", sender: isMydata)
        } else {
//            let challengerChallenge = challengerDaysChallenge[indexPath.row]
            let isMydata = false
            certainDayChallenge = challengerDaysChallenge[indexPath.row]
            performSegue(withIdentifier: "todayChallengeSegue", sender: isMydata)
        }
    }
    
}

extension SingleChallengeVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadDays data: [QueryDocumentSnapshot], type: DataType) {
        switch type {
        case .owner:
            myDaysChallenge.removeAll()
            for document in data {
                let aDayChallenge = DaysChallenge(
                    index: document["index"] as? Int ?? 0,
                    title: document["title"] as? String ?? "no title",
                    describe: document["describe"] as? String ?? "no describe",
                    image: document["image"] as? String ?? "no image",
                    createdTime: document["createdTime"] as? String ?? "no created time")
                myDaysChallenge.append(aDayChallenge)
            }
            challengeCollectionView.reloadData()
        case .challenger:
            challengerDaysChallenge.removeAll()
            for document in data {
                let aDayChallenge = DaysChallenge(
                    index: document["index"] as? Int ?? 0,
                    title: document["title"] as? String ?? "no title",
                    describe: document["describe"] as? String ?? "no describe",
                    image: document["image"] as? String ?? "no image",
                    createdTime: document["createdTime"] as? String ?? "no created time")
                challengerDaysChallenge.append(aDayChallenge)
            }
            challengeCollectionView.reloadData()
        case .challengeRequest, .comments, .friendRequest, .friends, .menu: break
        }
    }
    
    func fireManager(_ manager: FirebaseManager, fetchDoc: [String: Any]) {
        //in order to get the challenger's name
        challengerName = fetchDoc["ownerName"] as? String
    }
}