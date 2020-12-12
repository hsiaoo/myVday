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
    
    @IBOutlet weak var aDayImageView: UIImageView!
    @IBOutlet weak var aDayTitleTextField: UITextField!
    @IBOutlet weak var aDayDescribeTextView: UITextView!
    @IBOutlet weak var editSaveBtn: UIButton!
    @IBOutlet weak var aDayBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var aDayChallengDetailView: UIView!
    
    var singleChallengeFromList: Challenge?
    var myDaysChallenge = [DaysChallenge]()
    var challengerDaysChallenge = [DaysChallenge]()
    let fireManager = FirebaseManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        detailSetting()
    }
    
    @IBAction func tappedEditSaveBtn(_ sender: Any) {
        aDayTitleTextField.isEnabled = true
        aDayDescribeTextView.isEditable = true
        editSaveBtn.imageView?.image = UIImage(systemName: "checkmark.circle")
    }
    
    @IBAction func closeDetailView(_ sender: Any) {
        aDayBottomConstraint.constant = -746
         UIViewPropertyAnimator.runningPropertyAnimator(
             withDuration: 0.5,
             delay: 0,
             options: .allowAnimatedContent,
             animations: {
                 self.aDayChallengDetailView.frame = CGRect(x: 0, y: 842, width: UIScreen.main.bounds.width, height: 746)
         },
             completion: nil)
        
        aDayTitleTextField.isEnabled = false
        aDayDescribeTextView.isEditable = false
        editSaveBtn.imageView?.image = UIImage(systemName: "pencil.circle.fill")
    }

    func detailSetting() {
        if let singleChallengeFromList = singleChallengeFromList {
            challengeTitleLabel.text = singleChallengeFromList.title
            challengeDescribeLabel.text = singleChallengeFromList.describe
            fireManager.fetchChallengeDetail(challengeId: singleChallengeFromList.challengeId, dataType: .owner)
            
            if singleChallengeFromList.vsChallengeId.isEmpty {
                return
            } else {
                //抓取對方的Days紀錄
                let vsId = singleChallengeFromList.vsChallengeId
                fireManager.fetchChallengeDetail(challengeId: vsId, dataType: .challenger)
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
            if indexPath.section == 0 {
                sectionHeader.leftTitleLabel.isHidden = false
                sectionHeader.leftTitleLabel.text = "Austin"
                sectionHeader.rightTitleLabel.isHidden = true
            } else {
                sectionHeader.rightTitleLabel.isHidden = false
                sectionHeader.rightTitleLabel.text = "Bella"
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
                    challengeCell.challengeImageView.image = UIImage(named: "blankTask")
                } else {
                    challengeCell.challengeImageView.image = UIImage(named: "completedTasks")
                }
            } else {
                if challengerDaysChallenge[indexPath.row].describe.isEmpty {
                    challengeCell.challengeImageView.image = UIImage(named: "blankTask")
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
            let myChallenge = myDaysChallenge[indexPath.row]
            aDayTitleTextField.text = myChallenge.title
            aDayDescribeTextView.text = myChallenge.describe
            editSaveBtn.isHidden = false
        } else {
            let challengersChallenge = challengerDaysChallenge[indexPath.row]
            aDayTitleTextField.text = challengersChallenge.title
            aDayDescribeTextView.text = challengersChallenge.describe
            editSaveBtn.isHidden = true
        }
        aDayBottomConstraint.constant = 0
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .allowAnimatedContent,
            animations: {
                self.aDayChallengDetailView.frame = CGRect(x: 0, y: 96, width: UIScreen.main.bounds.width, height: 746)
        },
            completion: nil)
    }
    
}

extension SingleChallengeVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadDays data: [QueryDocumentSnapshot], type: DataType) {
        switch type {
        case .owner:
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
        case .challengeRequests, .comments, .friendRequests, .friends, .menu: break
        }
    }
}
