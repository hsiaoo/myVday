//
//  PlaceMarker.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/29.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import GoogleMaps
/*
class PlaceMarker: GMSMarker {
  // 1
  let place: GooglePlace

  // 2
  init(place: GooglePlace, availableTypes: [String]) {
    self.place = place
    super.init()

    position = place.coordinate
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = .pop

    var foundType = "restaurant"
    let possibleTypes = availableTypes.isEmpty ? ["bakery", "bar", "cafe", "vegan", "restaurant"] : availableTypes
//    let possibleTypes = availableTypes.count > 0 ? availableTypes : ["bakery", "bar", "cafe", "vegan", "restaurant"]

    for type in place.types {
      if possibleTypes.contains(type) {
        foundType = type
        break
      }
    }
    icon = UIImage(named: foundType+"_pin")
  }
}
*/
