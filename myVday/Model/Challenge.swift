//
//  Challenge.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/10.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation

struct Challenge {
    let challengeId: String
    let owner: String
    let title: String
    let describe: String
    let days: Int
    let vsChallengeId: String
    let updatedTime: String
    let isCompleted: Bool
}

struct DaysChallenge {
    let index: Int
    let title: String
    let describe: String
    let image: String
    let createdTime: String
}
