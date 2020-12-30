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
    
    @IBOutlet weak var restNameLabel: UILabel!
    @IBOutlet weak var restAddressLabel: UILabel!
    @IBOutlet weak var restaurantTableView: UITableView!
    
    let firebaseManager = FirebaseManager()
    let tagColor: [UIColor] = [#colorLiteral(red: 0.5244301558, green: 0.7633284926, blue: 1, alpha: 1), #colorLiteral(red: 0.5922563672, green: 1, blue: 0.5390954018, alpha: 1), #colorLiteral(red: 1, green: 0.6866127253, blue: 0.4180601537, alpha: 1), #colorLiteral(red: 1, green: 0.6486006975, blue: 0.792445004, alpha: 1), #colorLiteral(red: 1, green: 0.956641376, blue: 0.5953657031, alpha: 1)]
    var basicInfo: BasicInfo?
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        if let basicInfo = basicInfo {
            settingInfo(basicInfo: basicInfo)
            firebaseManager.fetchSubCollections(restaurantId: basicInfo.restaurantId, type: .comments)
        }
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
    
    func settingInfo(basicInfo: BasicInfo) {
        restNameLabel.text = basicInfo.name
        restAddressLabel.text = basicInfo.address
    }

}

extension DetailRestaurantVC: UITableViewDelegate, UITableViewDataSource {
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
            if let describeCell = tableView.dequeueReusableCell(
                withIdentifier: DescribeTableViewCell.identifier,
                for: indexPath) as? DescribeTableViewCell {
                
                if let restaurantInfo = basicInfo {
                    //new line command(\n)
                    let rawDescribe = restaurantInfo.describe
                    describeCell.restDescribeLabel.text = rawDescribe.replacingOccurrences(of: "/n", with: "\n")
                } else {
                    print("======there is no basic information of the restaurant======")
                }
                
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "檢舉") { ( _, view, completion) in
            let reportAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
                let reportedData = self.comments[indexPath.row]
                
                //加入黑名單
                let blockUser = UIAlertAction(title: "加入黑名單", style: .destructive) { _ in
                    self.firebaseManager.report(
                        mainCollection: .user,
                        mainDocId: userId,
                        subCollection: .flagUser,
                        reportedId: reportedData.userId,
                        reportedData: reportedData)
                }
                
                //檢舉評論
                let blockComment = UIAlertAction(title: "檢舉評論", style: .destructive) { _ in
                    self.firebaseManager.report(
                        mainCollection: .user,
                        mainDocId: userId,
                        subCollection: .flagComment,
                        reportedId: reportedData.commentId,
                        reportedData: reportedData)
                }
                
                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                reportAlertController.addAction(blockUser)
                reportAlertController.addAction(blockComment)
                reportAlertController.addAction(cancel)
                
            }
            // so that iPads won't crash
            reportAlertController.popoverPresentationController?.sourceView = self.view
            
            self.present(reportAlertController, animated: true, completion: nil)
            
            //使table view cell回到原先的位置
            completion(true)
        }
        //讓檢舉按鈕變成圓形驚嘆號
        contextItem.image = UIImage(systemName: "exclamationmark.circle")
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
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
                
                let newComment = Comment(
                    commentId: comment["commentId"] as? String ?? "no comment id",
                    name: comment["name"] as? String ?? "no user name",
                    comment: comment["comment"] as? String ?? "no comment",
                    date: okDate,
                    userId: comment["userId"] as? String ?? "no user id")
                comments.append(newComment)
            }
            restaurantTableView.reloadData()
        case .friends, .friendRequest, .challengeRequest, .challenger, .owner, .menu: break
        }
    }
}
