//
//  MenuVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/1.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import Firebase

class MenuVC: UIViewController {

    @IBOutlet weak var menuCollectionView: UICollectionView!
    let fireManager = FirebaseManager()
    var restId: String? = ""
    var restMenu = [Menu]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        if let restId = restId {
            fireManager.fetchSubCollections(docId: restId, type: .menu)
        }
    }

}

extension MenuVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        restMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let menuCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MenuCollectionViewCell.identifier,
            for: indexPath
            ) as? MenuCollectionViewCell {
            menuCell.cuisineName.text = restMenu[indexPath.row].cuisineName
            
            if let imageUrl = URL(string: "\(restMenu[indexPath.row].image)") {
                URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                    if let err = error {
                        print("Error getting image:\(err)")
                    }
                    if let okData = data {
                        DispatchQueue.main.async {
                            menuCell.imageView.image = UIImage(data: okData)
                        }
                    }
                }.resume()
            }
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
        return CGSize(width: sizeWidth, height: sizeWidth)
    }
}

extension MenuVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownload detailData: [QueryDocumentSnapshot], type: DataType) {
        for menu in detailData {
            let newCuisine = Menu(
                cuisineName: menu["cuisineName"] as? String ?? "no cuisine name",
                describe: menu["describe"] as? String ?? "no describe",
                image: menu["image"] as? String ?? "no image")
            restMenu.append(newCuisine)
        }
        menuCollectionView.reloadData()
    }
}
