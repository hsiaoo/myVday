//
//  Challenge.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/10.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation

struct Challenge: Codable {
    let challengeId: String
    let ownerId: String
    let ownerName: String
    let title: String
    let describe: String
    let days: Int
    let vsChallengeId: String
    let updatedTime: String
    let daysCompleted: Int
}

struct DaysChallenge {
    let index: Int
    var title: String
    var describe: String
    let image: String
    let createdTime: String
}
