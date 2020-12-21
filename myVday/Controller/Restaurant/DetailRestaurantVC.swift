//
//  DetailRestaurantVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DetailRestaurantVC: UIViewController {
    
    // MARK: Detail View
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var restDetailTableView: UITableView!
    
    let firebaseManager = FirebaseManager()
    let tagColor: [UIColor] = [#colorLiteral(red: 0.5244301558, green: 0.7633284926, blue: 1, alpha: 1), #colorLiteral(red: 0.5922563672, green: 1, blue: 0.5390954018, alpha: 1), #colorLiteral(red: 1, green: 0.6866127253, blue: 0.4180601537, alpha: 1), #colorLiteral(red: 1, green: 0.6486006975, blue: 0.792445004, alpha: 1), #colorLiteral(red: 1, green: 0.956641376, blue: 0.5953657031, alpha: 1)]
    var basicInfo: BasicInfo?
    var comments = [Comments]()
//    var voteCommentUserInput = (restaurantId: "", favCuisine: "", describe: "")
//    var allCuisineName = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.delegate = self
        navigationController?.navigationBar.isHidden = false
//        if let basicInfo = basicInfo {
//            settingInfo(basicInfo: basicInfo)
//            firebaseManager.fetchSubCollections(restaurantId: basicInfo.restaurantId, type: .comments)
//            firebaseManager.listener(dataType: .comments)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let basicInfo = basicInfo {
            settingInfo(basicInfo: basicInfo)
            firebaseManager.fetchSubCollections(restaurantId: basicInfo.restaurantId, type: .comments)
        }
    }
    
    // MARK: Actions in Detail VC
    @IBAction func goToMenuBtn(_ sender: UIBarButtonItem) {
        if let restId = basicInfo?.restaurantId {
            performSegue(withIdentifier: "toMenuSegue", sender: restId)
        }
    }
    
    @IBAction func writeCommentBtn(_ sender: UIBarButtonItem) {
        if let restId = basicInfo?.restaurantId {
            performSegue(withIdentifier: "writeCommentSegue", sender: restId)
        }
    }
    
    // MARK: functions
    func settingInfo(basicInfo: BasicInfo) {
        restaurantName.text = basicInfo.name
        addressLabel.text = basicInfo.address
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMenuSegue" {
            let menuVC = segue.destination as? MenuVC
            menuVC?.restaurantId = sender as? String
        } else {
            let writeCommentVC = segue.destination as? WriteCommentVC
            writeCommentVC?.restaurantId = sender as? String
        }
    }
    
    @objc func writeComment() {
//        isWritingComment = true
//        guard let restaurantId = basicInfo?.restaurantId else { return }
//        firebaseManager.fetchSubCollections(restaurantId: restaurantId, type: .menu)
//        commentVoteView.layer.shadowColor = UIColor.yellow.cgColor
//        commentVoteView.layer.shadowOffset = CGSize(width: 10, height: 20)
//        commentVoteView.layer.shadowRadius = 8
//        commentVoteView.layer.shadowOpacity = 1
    }
}

extension DetailRestaurantVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3 {
            if let headerView = Bundle.main.loadNibNamed("CustomSectionHeader",
                owner: self,
                options: nil)?.first as? CustomSectionHeader {
                headerView.sectionTitleLabel.text = "其他人覺得.."
                headerView.commentBtn.addTarget(self, action: #selector(writeComment), for: .touchUpInside)
                return headerView
            }
        }
        return UIView()
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 46
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 7
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let describeCell = tableView.dequeueReusableCell(withIdentifier: DescribeTableViewCell.identifier, for: indexPath) as? DescribeTableViewCell {
                describeCell.restDescribeLabel.text = basicInfo?.describe
                return describeCell
            }
        } else if indexPath.section == 1 {
            if let hoursCell = tableView.dequeueReusableCell(withIdentifier: HoursTableViewCell.identifier, for: indexPath) as? HoursTableViewCell {
                hoursCell.restHoursLabel.text = basicInfo?.hours[indexPath.row]
                return hoursCell
            }
        } else {
            if let commentsCell = tableView.dequeueReusableCell(
                withIdentifier: CommentTableViewCell.identifier,
                for: indexPath
                ) as? CommentTableViewCell {
                commentsCell.commentNameLabel.text = self.comments[indexPath.row].name
                commentsCell.commentDateLabel.text = self.comments[indexPath.row].date
                commentsCell.commentLabel.text = self.comments[indexPath.row].comment
                return commentsCell
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
    
}

extension DetailRestaurantVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        basicInfo?.hashtags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let hashtagCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailRestaurantCollectionViewCell.identifier,
            for: indexPath
            ) as? DetailRestaurantCollectionViewCell {
            hashtagCell.layer.cornerRadius = 5
            hashtagCell.clipsToBounds = true
            
            if let hashtagArray = basicInfo?.hashtags {
                if hashtagArray[indexPath.row].isEmpty {
                    //若無任何標籤，底色變為透明
                    hashtagCell.backgroundColor = .clear
                } else {
                    //若標籤數量大於背景顏色數量(5)，要重複使用背景顏色
                    if indexPath.row > 4 {
                        let index = indexPath.row % 5
                        hashtagCell.backgroundColor = tagColor[index]
                    } else {
                        hashtagCell.backgroundColor = tagColor[indexPath.row]
                    }
                }
            }
            
            hashtagCell.tagLabel.text = basicInfo?.hashtags[indexPath.row]
            return hashtagCell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension DetailRestaurantVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadDetail data: [QueryDocumentSnapshot], type: DataType) {
        switch type {
        case .comments:
            comments.removeAll()
            for comment in data {
                //轉換日期與時間
                guard let dateStamp = comment["date"] as? Timestamp  else { return }
                let dateData = dateStamp.dateValue()
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = NSTimeZone.local
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let okDate = dateFormatter.string(from: dateData)
                
                let newComment = Comments(
                    commentId: comment["commentId"] as? String ?? "no comment id",
                    name: comment["name"] as? String ?? "no user name",
                    comment: comment["comment"] as? String ?? "no comment",
                    date: okDate)
                comments.append(newComment)
            }
            restDetailTableView.reloadData()
        case.menu: break
//            for menu in data {
//                let cuisineName = menu["cuisineName"] as? String ?? ""
//                allCuisineName.append(cuisineName)
//            }
        case .friends, .friendRequest, .challengeRequest, .challenger, .owner: break
        }
    }
    
//    func fireManager(_ manager: FirebaseManager, didDownloadCuisine: [String: Any]) {
//        if let currentVote = didDownloadCuisine["vote"] as? Int {
//            firebaseManager.updateVote(
//                restaurantId: voteCommentUserInput.restaurantId,
//                cuisineName: voteCommentUserInput.favCuisine,
//                newValue: currentVote + 1)
//        }
//    }
    
//    func fireManager(_ manager: FirebaseManager, didFinishUpdate menuOrComment: DataType) {
//        comments = [Comments]()
//        if let restaurantId = basicInfo?.restaurantId {
//            firebaseManager.fetchSubCollections(restaurantId: restaurantId, type: .comments)
//        }
//        commentTextView.resignFirstResponder()
//        voteTF.resignFirstResponder()
//        isWritingComment = false
//        restDetailTableView.reloadData()
//    }
}
