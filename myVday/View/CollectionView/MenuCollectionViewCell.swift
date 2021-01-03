//
//  MenuCollectionViewCell.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/1.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    static let identifier = "menuCell"
    let imageManager = ImageManager()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cuisineImageView: UIImageView!
    @IBOutlet weak var cuisineName: UILabel!
    
    override func awakeFromNib() {
        imageManager.imageDelegate = self
        self.layer.cornerRadius = 10.0
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    
    func setUpMenuCell(with cuisine: Menu) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        cuisineName.text = cuisine.cuisineName
        imageManager.downloadImage(imageSting: cuisine.image)
    }
    
}

extension MenuCollectionViewCell: ImageManagerDelegate {
    func imageManager(_ manager: ImageManager, getData image: Data) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.cuisineImageView.image = UIImage(data: image)
        }
    }
}
