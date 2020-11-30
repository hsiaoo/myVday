//
//  FirebaseManager.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/29.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol FirebaseManagerDelegate: AnyObject {
    func didDownloadData()
}

class FirebaseManager {
    let fireDB = Firestore.firestore()
    weak var delegate: FirebaseManagerDelegate?
    
    //fetch data from firebase
    
}
