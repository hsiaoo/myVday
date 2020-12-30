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
    
    let fireManager = FirebaseManager()
    var restaurantId: String? = ""
    var restaurantMenu = [Menu]()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let restId = restaurantId {
            fireManager.fetchSubCollections(restaurantId: restId, type: .menu)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCuisineSegue" {
            if let controller = segue.destination as? AddCuisineVC {
                controller.restId = restaurantId
            }
        }
    }
    
    @IBAction func addCuisineBarBtn(_ sender: Any) {
        performSegue(withIdentifier: "addCuisineSegue", sender: nil)
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
            menuCell.activityIndicator.isHidden = false
            menuCell.activityIndicator.startAnimating()
            menuCell.cuisineName.text = restaurantMenu[indexPath.row].cuisineName
            
            if let imageUrl = URL(string: "\(restaurantMenu[indexPath.row].image)") {
                URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                    if let err = error {
                        print("Error getting image:\(err)")
                    }
                    if let okData = data {
                        DispatchQueue.main.async {
                            menuCell.imageView.image = UIImage(data: okData)
                            menuCell.activityIndicator.stopAnimating()
                            menuCell.activityIndicator.isHidden = true
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
