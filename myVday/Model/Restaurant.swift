//
//  BasicInfo.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/30.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation

struct BasicInfo: Codable {
    let address: String
    let describe: String
    let hashtags: [String]
    let hots: [String]
    let hours: [String]
    let restaurantId: String
    let latitude: Double
    let longitude: Double
    let name: String
    let phone: String
}

struct Comments {
    let commentId: String
    let name: String
    let comment: String
    let date: String
}

struct Menu: Codable {
    var cuisineName: String
    var describe: String
    var image: String
    var vote: Int
}

struct NewRestaurant {
    let basicInfo: BasicInfo
}
