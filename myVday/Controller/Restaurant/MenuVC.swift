//
//  MenuVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/1.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MenuVC: UIViewController {

    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var noCuisineLabel: UILabel!

    let firebaseManager = FirebaseManager.instance
    let refresher = UIRefreshControl()
    var restaurantId: String? = ""
    var restaurantMenu = [Menu]()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseManager.delegate = self
        
        //download dishes from firestore
        if let restId = restaurantId {
            firebaseManager.fetchSubCollections(restaurantId: restId, type: .menu)
        }
        
        //pull to refresh
        refresher.attributedTitle = NSAttributedString(string: "更新餐點...🤩")
        refresher.addTarget(self, action: #selector(updateMenu), for: .valueChanged)
        menuCollectionView.addSubview(refresher)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCuisineSegue" {
            if let controller = segue.destination as? AddCuisineVC {
                controller.restId = restaurantId
                
                //將AddCuisineVC傳過來的新餐點加進restaruantMenu，並重載collection view
                controller.insertCuisineItem = { cuisineName, cuisineImageString in
                    let newCusine = Menu(cuisineName: cuisineName, describe: "", image: cuisineImageString, vote: 0)
                    self.restaurantMenu.append(newCusine)
                    self.menuCollectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func addCuisineBarBtn(_ sender: Any) {
        performSegue(withIdentifier: "addCuisineSegue", sender: nil)
    }
    
    @objc func updateMenu() {
        if let restId = restaurantId {
            firebaseManager.fetchSubCollections(restaurantId: restId, type: .menu)
        }
        refresher.endRefreshing()
    }
}

extension MenuVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        restaurantMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let menuCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MenuCollectionViewCell.identifier,
            for: indexPath
            ) as? MenuCollectionViewCell {
            let aCuisine = restaurantMenu[indexPath.row]
            menuCell.setUpMenuCell(with: aCuisine)
            return menuCell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension MenuVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let sizeWidth = (screenWidth - 16 * 3) / 2
        let sizeHeight = sizeWidth + 40
        return CGSize(width: sizeWidth, height: sizeHeight)
    }
}

extension MenuVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadDetail data: [QueryDocumentSnapshot], type: DataType) {
        restaurantMenu.removeAll()
        for menu in data {
            let newCuisine = Menu(
                cuisineName: menu["cuisineName"] as? String ?? "no cuisine name",
                describe: menu["describe"] as? String ?? "no describe",
                image: menu["image"] as? String ?? "no image",
                vote: menu["vote"] as? Int ?? 0)
            restaurantMenu.append(newCuisine)
        }
        
        if restaurantMenu.isEmpty {
            noCuisineLabel.isHidden = false
        } else {
            noCuisineLabel.isHidden = true
        }
        menuCollectionView.reloadData()
    }
    
}
