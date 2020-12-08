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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cuisineName: UILabel!
}