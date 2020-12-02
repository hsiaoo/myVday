//
//  BasicInfo.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/30.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation

struct BasicInfo {
    let address: String
    let describe: String
    let hashtags: [String]
    let hots: [String]
    let hours: [String: String]
    let basicId: String
    let latitude: Double
    let longitude: Double
    let name: String
    let phone: String
}

struct Comments {
    let userId: String
    let describe: String
    let date: String
}

struct Menu {
    let cuisineName: String
    let describe: String
    let image: String
//    let vote: Int
}
