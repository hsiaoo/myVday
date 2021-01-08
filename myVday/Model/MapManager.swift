//
//  MapManager.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/7.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapManagerDelegate: AnyObject {
    func mapManager(_ manager: MapManager, didGetCoordinate: CLPlacemark, name: String, address: String)
}

class MapManager {
    weak var delegate: MapManagerDelegate?
    let geoCoder = CLGeocoder()
    
    func addressToCoordinate(newRestName: String, newRestAddress: String) {
        geoCoder.geocodeAddressString(newRestAddress) { (placemarks, error) in
            if let err = error {
                print("Error getting coordinate: \(err)")
            } else {
                if let placemarks = placemarks {
                    let placemark = placemarks[0] as CLPlacemark
                    self.delegate?.mapManager(self, didGetCoordinate: placemark, name: newRestName, address: newRestAddress)
                }
            }
        }
    }
}
