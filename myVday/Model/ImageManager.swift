//
//  ImageManager.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/1/2.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

protocol ImageManagerDelegate: AnyObject {
    func imageManager(_ manager: ImageManager, getData image: Data)
}

import Foundation

class ImageManager {
    weak var imageDelegate: ImageManagerDelegate?
    
    func downloadImage(imageSting: String) {
        if let imageUrl = URL(string: imageSting) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                if let err = error {
                    print("Error download user photo: \(err)")
                }
                if let okData = data {
                    self.imageDelegate?.imageManager(self, getData: okData)
                }
            }.resume()
        }
    }
    
}
