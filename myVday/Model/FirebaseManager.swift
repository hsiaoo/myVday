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
    func fireManager(_ manager: FirebaseManager, didDownload basicData: [QueryDocumentSnapshot])
    func fireManager(_ manager: FirebaseManager, didDownload detailData: [QueryDocumentSnapshot], type: DataType)
}

enum DataType: String, CaseIterable {
    case comments = "comments"
    case hashtags = "hashtags"
    case hours = "hours"
}

class FirebaseManager {
    let fireDB = Firestore.firestore()
    let dataType = DataType.allCases
    var restaurantId = [String]()
    weak var delegate: FirebaseManagerDelegate?
    
    //fetch basic data of restaurant from firebase
    func fetchData() {
        fireDB.collection("Restaurant").getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting docs: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    for document in docArray {
                        let id = document.documentID
                        self.restaurantId.append(id)
                    }
                    for type in self.dataType {
                        self.fetchSubCollections(type: type)
                    }
                    self.delegate?.fireManager(self, didDownload: docArray)
                }
            }
        }
    }
    
    func fetchSubCollections(type: DataType) {
        for rstId in restaurantId {
            fireDB.collection("Restaurant").document(rstId).collection(type.rawValue).getDocuments { (snapshot, error) in
                if let err = error {
                    print("Error getting docs: \(err)")
                } else {
                    if let docArray = snapshot?.documents {
                        self.delegate?.fireManager(self, didDownload: docArray, type: type)
                    }
                }
            }
        }
    }
}
