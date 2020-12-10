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
    
    @IBOutlet weak var moreInfoBtn: UIButton!
    
    @IBOutlet weak var moreInfoConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var describeLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    
    // MARK: Writing and Voting View
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var commentVoteView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var btnOnPhotoImage: UIButton!
    @IBOutlet weak var voteTF: UITextField!
    @IBOutlet weak var commentTopStackView: UIStackView!
    @IBOutlet weak var commentVoteStackView: UIStackView!
    @IBOutlet weak var commentBtnStackView: UIStackView!
    @IBOutlet weak var doneBtnOulet: UIButton!
    
    let firebaseManager = FirebaseManager()
    let picker = UIPickerView()
    let tagColor: [UIColor] = [#colorLiteral(red: 0.5244301558, green: 0.7633284926, blue: 1, alpha: 1), #colorLiteral(red: 0.5922563672, green: 1, blue: 0.5390954018, alpha: 1), #colorLiteral(red: 1, green: 0.6866127253, blue: 0.4180601537, alpha: 1), #colorLiteral(red: 1, green: 0.6486006975, blue: 0.792445004, alpha: 1), #colorLiteral(red: 1, green: 0.956641376, blue: 0.5953657031, alpha: 1)]
    var basicInfo: BasicInfo?
    var comments = [Comments]()
    var voteCommentUserInput = (restaurantId: "", favCuisine: "", describe: "")
    var allCuisineName = [String]()
    var isWritingComment = true {
        didSet {
            if isWritingComment == true {
                maskView.isHidden = false
                commentTopStackView.isHidden = false
                commentVoteStackView.isHidden = false
                commentBtnStackView.isHidden = false
                btnOnPhotoImage.isHidden = false
                commentVoteView.isHidden = false
            } else {
                maskView.isHidden = true
                commentTopStackView.isHidden = true
                commentVoteStackView.isHidden = true
                commentBtnStackView.isHidden = true
                btnOnPhotoImage.isHidden = true
                commentVoteView.isHidden = true
                commentTextView.text = ""
                photoImageView.image = nil
                voteTF.text = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let basicInfo = basicInfo {
            isWritingComment = false
            settingInfo(basicInfo: basicInfo)
            firebaseManager.delegate = self
            firebaseManager.fetchSubCollections(restaurantId: basicInfo.basicId, type: .comments)
//            firebaseManager.listener(dataType: .comments)
            voteTF.inputView = picker
            picker.delegate = self
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    // MARK: Actions in Detail VC
    @IBAction func goToMenuBtn(_ sender: UIBarButtonItem) {
        if let restId = basicInfo?.basicId {
            performSegue(withIdentifier: "toMenuSegue", sender: restId)
        }
    }
    
    // MARK: Actions in Comment&Vote View
    @IBAction func addPhotoBtn(_ sender: Any) {
        
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        commentTextView.resignFirstResponder()
        voteTF.resignFirstResponder()
        isWritingComment = false
    }
    
    @IBAction func doneBtn(_ sender: Any) {
        voteCommentUserInput.describe = commentTextView.text ?? ""
        
        if voteCommentUserInput.describe.isEmpty {
            print("describe is empty")
        } else {
            guard let restaurantId = basicInfo?.basicId else { return }
            let favCuisine = voteTF.text ?? ""
            
            if photoImageView.image == nil {
                firebaseManager.addComment(
                    toFirestoreWith: restaurantId,
                    userId: "Austin",
                    describe: voteCommentUserInput.describe,
                    image: "")
            } else {
                let uniqueString = NSUUID().uuidString
                if let photoImage = photoImageView.image {
                    firebaseManager.uploadImage(
                        toStorageWith: restaurantId,
                        uniqueString: uniqueString,
                        selectedImage: photoImage,
                        nameOrDescribe: voteCommentUserInput.describe,
                        dataType: .comments)
                }
            }
            
            if favCuisine.isEmpty {
                return
            } else {
                voteCommentUserInput.restaurantId = restaurantId
                voteCommentUserInput.favCuisine = favCuisine
                firebaseManager.fetchCertainCuisine(restaurantId: restaurantId, cuisineName: favCuisine)
            }
            //        commentTextView.resignFirstResponder()
            //        voteTF.resignFirstResponder()
            //        isWritingComment = false
        }
    }
    
    // MARK: functions
    func settingInfo(basicInfo: BasicInfo) {
        restaurantName.text = basicInfo.name
        addressLabel.text = basicInfo.address
        describeLabel.text = basicInfo.describe
        sundayLabel.text = basicInfo.hours["sunday"]
        mondayLabel.text = basicInfo.hours["monday"]
        tuesdayLabel.text = basicInfo.hours["tuesday"]
        wednesdayLabel.text = basicInfo.hours["wednesday"]
        thursdayLabel.text = basicInfo.hours["thursday"]
        fridayLabel.text = basicInfo.hours["friday"]
        saturdayLabel.text = basicInfo.hours["saturday"]
        if basicInfo.describe.isEmpty && basicInfo.hours.isEmpty {
            moreInfoView.isHidden = true
            moreInfoConstraint.constant = 20
        } else {
            moreInfoView.isHidden = false
            let height = moreInfoView.frame.height
            moreInfoConstraint.constant = height
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMenuSegue" {
            let menuVC = segue.destination as? MenuVC
            menuVC?.restaurantId = sender as? String
        }
    }
    
    @objc func writeComment() {
        isWritingComment = true
        guard let restaurantId = basicInfo?.basicId else { return }
        firebaseManager.fetchSubCollections(restaurantId: restaurantId, type: .menu)
//        commentVoteView.layer.shadowColor = UIColor.yellow.cgColor
//        commentVoteView.layer.shadowOffset = CGSize(width: 10, height: 20)
//        commentVoteView.layer.shadowRadius = 8
//        commentVoteView.layer.shadowOpacity = 1
    }
}

extension DetailRestaurantVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = Bundle.main.loadNibNamed("CustomSectionHeader", owner: self, options: nil)?.first as? CustomSectionHeader {
            headerView.sectionTitleLabel.text = "其他人覺得.."
            headerView.commentBtn.addTarget(self, action: #selector(writeComment), for: .touchUpInside)
            return headerView
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let detailCell = tableView.dequeueReusableCell(
            withIdentifier: DetailRestaurantTableViewCell.identifier,
            for: indexPath
            ) as? DetailRestaurantTableViewCell {
            detailCell.userIdLabel.text = self.comments[indexPath.row].userId
            detailCell.dateLabel.text = self.comments[indexPath.row].date
            detailCell.describeLabel.text = self.comments[indexPath.row].describe
            
            let imageString = comments[indexPath.row].image
            if imageString.isEmpty {
                print("no image")
            } else {
                if let imageUrl = URL(string: imageString) {
                    URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
                        if let err = error {
                            print("Error downloaded image: \(err)")
                        } else {
                            if let imageData = data {
                                detailCell.imageViewForComment.image = UIImage(data: imageData)
                            }
                        }
                    }.resume()
                }
            }
            return detailCell
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

extension DetailRestaurantVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        allCuisineName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        allCuisineName[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        voteTF.text = allCuisineName[row]
    }
    
}

//extension DetailRestaurantVC: UITextViewDelegate {
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if voteCommentUserInput.describe.isEmpty {
//            return
//        } else {
//            doneBtnOulet.isEnabled = true
//        }
//        print("did end editing")
//
//    }
//}

extension DetailRestaurantVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadDetail data: [QueryDocumentSnapshot], type: DataType) {
        switch type {
        case .comments:
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
                    userId: comment["userId"] as? String ?? "no user id",
                    describe: comment["describe"] as? String ?? "no describe",
                    image: comment["image"] as? String ?? "no image",
                    date: okDate)
                comments.append(newComment)
            }
            commentTableView.reloadData()
        case.menu:
            for menu in data {
                let cuisineName = menu["cuisineName"] as? String ?? ""
                allCuisineName.append(cuisineName)
            }
        case .friends, .friendRequests, .challengeRequests: break
        }
    }
    
    func fireManager(_ manager: FirebaseManager, didDownloadCuisine: [String: Any]) {
        if let currentVote = didDownloadCuisine["vote"] as? Int {
            firebaseManager.updateVote(
                restaurantId: voteCommentUserInput.restaurantId,
                cuisineName: voteCommentUserInput.favCuisine,
                newValue: currentVote + 1)
        }
    }
    
    func fireManager(_ manager: FirebaseManager, didFinishUpdate menuOrComment: DataType) {
        comments = [Comments]()
        if let restaurantId = basicInfo?.basicId {
            firebaseManager.fetchSubCollections(restaurantId: restaurantId, type: .comments)
        }
        commentTextView.resignFirstResponder()
        voteTF.resignFirstResponder()
        isWritingComment = false
        commentTableView.reloadData()
    }
}
