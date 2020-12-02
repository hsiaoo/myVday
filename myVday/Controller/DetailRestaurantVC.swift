//
//  DetailRestaurantVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class DetailRestaurantVC: UIViewController {
    
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
//    let tagColor: [UIColor] = [.blue, .brown, .cyan, .green, .orange]
    let tagColor: [UIColor] = [#colorLiteral(red: 0.5244301558, green: 0.7633284926, blue: 1, alpha: 1), #colorLiteral(red: 0.5922563672, green: 1, blue: 0.5390954018, alpha: 1), #colorLiteral(red: 1, green: 0.6866127253, blue: 0.4180601537, alpha: 1), #colorLiteral(red: 1, green: 0.6486006975, blue: 0.792445004, alpha: 1), #colorLiteral(red: 1, green: 0.956641376, blue: 0.5953657031, alpha: 1)]
    var basicInfo: BasicInfo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let basicInfo = basicInfo {
            settingInfo(basicInfo: basicInfo)
        }
    }
    
    @IBAction func goToMenuBtn(_ sender: UIBarButtonItem) {
        if let restId = basicInfo?.basicId {
            performSegue(withIdentifier: "toMenuSegue", sender: restId)
        }
    }
    
    @IBAction func showInfoBtn(_ sender: Any) {
        moreInfoView.isHidden = false
        let height = moreInfoView.frame.height
        moreInfoConstraint.constant = height
    }
    
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
            moreInfoConstraint.constant = 10
        } else {
            moreInfoView.isHidden = false
            let height = moreInfoView.frame.height
            moreInfoConstraint.constant = height
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMenuSegue" {
            let menuVC = segue.destination as? MenuVC
            menuVC?.restId = sender as? String
        }
    }
}

extension DetailRestaurantVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let detailCell = tableView.dequeueReusableCell(
            withIdentifier: DetailRestaurantTableViewCell.identifier,
            for: indexPath
            ) as? DetailRestaurantTableViewCell {
            
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
            hashtagCell.backgroundColor = tagColor[indexPath.row]
            hashtagCell.tagLabel.text = basicInfo?.hashtags[indexPath.row]
            return hashtagCell
        } else {
            return UICollectionViewCell()
        }
    }
    
}
