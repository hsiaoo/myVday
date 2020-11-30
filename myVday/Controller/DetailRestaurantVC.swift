//
//  DetailRestaurantVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/27.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class DetailRestaurantVC: UIViewController {
    
    @IBOutlet weak var moreInfoBtn: UIButton!
    @IBOutlet weak var moreInfoConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreInfoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showInfoBtn(_ sender: Any) {
        moreInfoView.isHidden = false
        let height = moreInfoView.frame.height
        moreInfoConstraint.constant = height
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
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let hashtagCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DetailRestaurantCollectionViewCell.identifier,
            for: indexPath
            ) as? DetailRestaurantCollectionViewCell {
            return hashtagCell
        } else {
            return UICollectionViewCell()
        }
    }
    
}
