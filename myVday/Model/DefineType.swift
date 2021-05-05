//
//  DefineType.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/5/3.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

import Foundation

enum SuccessOrFail {
    case success, fail
}

enum ProfileImageStatus {
    case old, new
}

/** Two cases of layout: List and New Request */
enum LayoutType {
    case list
    case newRequest
}

/**  Two cases of action: Accept and Delete */
enum ActionType {
    case accept
    case delete
}

@objc enum MainCollection: Int {
    case challenge, restaurant, user

    func name() -> String {
        switch self {
        case .challenge: return "Challenge"
        case .restaurant: return "Restaurant"
        case .user: return "User"
        }
    }
}

@objc enum SubCollection: Int {
    case days, comments, menu, friends, challengeRequest, friendRequest, flagComment, flagUser
    
    func name() -> String {
        switch self {
        case .days: return "Days"
        case .comments: return "comments"
        case .menu: return "menu"
        case .friends: return "friends"
        case .challengeRequest: return "challengeRequest"
        case .friendRequest: return "friendRequest"
        case .flagComment: return " flagComment"
        case .flagUser: return "flagUser"
        }
    }
}

@objc enum ImageType: Int {
    case menu, challenge
    
    func name() -> String {
        switch self {
        case .menu: return "menu"
        case .challenge: return "challenge"
        }
    }
}

@objc enum DataType: Int {
    case comments
    case menu
    case friends
    case friendRequest
    case challengeRequest
    case owner
    case challenger
    
    func name() -> String {
        switch self {
        case .comments: return "comments"
        case .menu: return "menu"
        case .friends: return "friends"
        case .friendRequest: return "friendRequest"
        case .challengeRequest: return "challengeRequest"
        case .owner: return "owner"
        case .challenger: return "challenger"
        }
    }
}
