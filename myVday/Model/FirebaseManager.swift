//
//  FirebaseManager.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/29.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation
import FirebaseFirestore

@objc protocol FirebaseManagerDelegate: AnyObject {
    @objc optional func fireManager(_ manager: FirebaseManager, didDownload basicData: [QueryDocumentSnapshot])
    @objc optional func fireManager(_ manager: FirebaseManager, didDownload detailData: [QueryDocumentSnapshot], type: DataType)
}

@objc enum DataType: Int {
    case comments
    case menu
    
    func name() -> String {
        switch self {
        case .comments: return "comments"
        case .menu: return "menu"
        }
    }
}

//enum DataType: NSString, CaseIterable {
//    case comments = "comments"
//    case menu = "menu"
//}

class FirebaseManager: NSObject {
    let fireDB = Firestore.firestore()
//    let dataType = DataType.allCases
    var restaurantId = [String]()
    weak var delegate: FirebaseManagerDelegate?
    
    //fetch basic data of restaurant from firebase
    func fetchData() {
        fireDB.collection("Restaurant").getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting docs: \(err)")
            } else {
                if let docArray = snapshot?.documents {
//                    for document in docArray {
//                        let id = document.documentID
//                        self.restaurantId.append(id)
//                    }
//                    for type in self.dataType {
//                        self.fetchSubCollections(type: type)
//                    }
                    self.delegate?.fireManager!(self, didDownload: docArray)
                }
            }
        }
    }
   
    func fetchSubCollections(docId: String, type: DataType) {
        fireDB.collection("Restaurant").document(docId).collection(type.name()).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting docs: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    self.delegate?.fireManager!(self, didDownload: docArray, type: type)
                }
            }
        }
    }
    
//    func fetchSubCollections(type: DataType) {
//        for rstId in restaurantId {
//            fireDB.collection("Restaurant").document(rstId).collection(type.rawValue).getDocuments { (snapshot, error) in
//                if let err = error {
//                    print("Error getting docs: \(err)")
//                } else {
//                    if let docArray = snapshot?.documents {
//                        self.delegate?.fireManager(self, didDownload: docArray, type: type)
//                    }
//                }
//            }
//        }
//    }
}
