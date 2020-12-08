//
//  MapInfoWindow.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/3.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

protocol MapInfoWindowDelegate: AnyObject {
    func didTapInfoButton(data: BasicInfo)
}

class MapInfoWindow: UIView {
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var hotCuisineFirst: UILabel!
    @IBOutlet weak var hotCuisineSecond: UILabel!
    @IBOutlet weak var tagFirst: UILabel!
    @IBOutlet weak var tagSecond: UILabel!
    
    weak var delegate: MapInfoWindowDelegate?
    var spotData: BasicInfo?
    
    @IBAction func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if let spotData = spotData {
            delegate?.didTapInfoButton(data: spotData)
        }
    }
    
    class func instanceFromNib() -> UIView {
        if let okView = UINib(nibName: "MapInfoWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
            return okView
        } else {
            return UIView()
        }
    }
    
//    class func loadViewFromNib() -> UIView {
//        var infoView = UIView()
//        if let okNib = UINib(nibName: "MapInfoWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView {
//            infoView = okNib
//            infoView.isUserInteractionEnabled = true
//            let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInfoView(sender:)))
//            infoView.addGestureRecognizer(recognizer)
//            return infoView
//        } else {
//            return UIView()
//        }
//    }
    
//    @objc func didTapInfoView(sender: UITapGestureRecognizer) {
//        if let spotData = spotData {
//            delegate?.didTapInfoButton(data: spotData)
//        }
//    }
    
}
