//
//  FirebaseManager.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/29.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CoreLocation

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

class FirebaseManager: NSObject {
    let fireDB = Firestore.firestore()
    weak var delegate: FirebaseManagerDelegate?
    
    //fetch basic information of restaurant from firebase
    func fetchData(current location: CLLocation) {
        var filteredArray = [QueryDocumentSnapshot]()
        let leftLat = location.coordinate.latitude - 0.001
        let rightLat = location.coordinate.latitude + 0.001
        let topLng = location.coordinate.longitude - 0.003
        let downLng = location.coordinate.longitude + 0.003
        
        fireDB.collection("Restaurant")
            .whereField("latitude", isLessThanOrEqualTo: rightLat)
            .whereField("latitude", isGreaterThanOrEqualTo: leftLat)
            .getDocuments { (snapshot, error) in
                if let err = error {
                    print("Error getting docs: \(err)")
                } else {
                    if let docArray = snapshot?.documents {
                        for doc in docArray {
                            let docData = doc.data()
                            let longitude = docData["longitude"] as? Double ?? 0
                            if longitude >= topLng && longitude <= downLng {
                                filteredArray.append(doc)
                            }
                        }
                        self.delegate?.fireManager?(self, didDownload: filteredArray)
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

}
