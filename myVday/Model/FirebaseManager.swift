//
//  FirebaseManager.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/29.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

@objc protocol FirebaseManagerDelegate: AnyObject {
    @objc optional func fireManager(_ manager: FirebaseManager, didDownloadBasic data: [QueryDocumentSnapshot])
    @objc optional func fireManager(_ manager: FirebaseManager, didDownloadDetail data: [QueryDocumentSnapshot], type: DataType)
    @objc optional func fireManager(_ manager: FirebaseManager, didDownloadCuisine: [String: Any])
    @objc optional func fireManager(_ manager: FirebaseManager, didFinishUpdate menuOrComment: DataType)
    @objc optional func fireManager(_ manager: FirebaseManager, didDownloadProfile data: [String: Any])
    @objc optional func fireManager(_ manager: FirebaseManager, didDownloadProfileDetail data: [QueryDocumentSnapshot], type: DataType)
    @objc optional func fireManager(_ manager: FirebaseManager, didDownloadChallenge data: [QueryDocumentSnapshot])
    @objc optional func fireManager(_ manager: FirebaseManager, didDownloadDays data: [QueryDocumentSnapshot], type: DataType)
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

class FirebaseManager: NSObject {
    let fireDB = Firestore.firestore()
    var ref: DocumentReference?
    weak var delegate: FirebaseManagerDelegate?
    
    //fetch basic information of restaurant from firebase
    func fetchData(current location: CLLocation) {
        var filteredArray = [QueryDocumentSnapshot]()
        let leftLat = location.coordinate.latitude - 0.003
        let rightLat = location.coordinate.latitude + 0.003
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
                        self.delegate?.fireManager?(self, didDownloadBasic: filteredArray)
                    }
                }
        }
    }
    
    func fetchSubCollections(restaurantId: String, type: DataType) {
        fireDB.collection("Restaurant").document(restaurantId).collection(type.name()).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting docs: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    self.delegate?.fireManager!(self, didDownloadDetail: docArray, type: type)
                }
            }
        }
    }
    
    func fetchCertainCuisine(restaurantId: String, cuisineName: String) {
        fireDB.collection("Restaurant").document(restaurantId).collection("menu").document(cuisineName).getDocument { (snapshot, error) in
            if let err = error {
                print("Error getting certain cuisine: \(err)")
            } else {
                if let document = snapshot?.data() {
                    self.delegate?.fireManager?(self, didDownloadCuisine: document)
                }
            }
        }
    }
    
    func fetchProfileData(userId: String) {
        fireDB.collection("User").document(userId).getDocument { (snapshot, error) in
            if let err = error {
                print("Error getting profile data: \(err)")
            } else {
                if let document = snapshot?.data() {
                    self.delegate?.fireManager?(self, didDownloadProfile: document)
                }
            }
        }
    }
    
    func fetchProfileSubCollection(userId: String, dataType: DataType) {
        fireDB.collection("User").document(userId).collection(dataType.name()).getDocuments { (snapeshot, error) in
            if let err = error {
                print("Error getting sub collection data: \(err)")
            } else {
                if let docArray = snapeshot?.documents {
                    self.delegate?.fireManager?(self, didDownloadProfileDetail: docArray, type: dataType)
                }
            }
        }
    }
    
    func fetchMyChallenge(ower: String) {
        fireDB.collection("Challenge").whereField("owner", isEqualTo: ower).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting challenge documents: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    self.delegate?.fireManager?(self, didDownloadChallenge: docArray)
                }
            }
        }
    }
    
    func fetchChallengeDetail(challengeId: String, dataType: DataType) {
        fireDB.collection("Challenge").document(challengeId).collection("Days").getDocuments { (snapshot, error) in
            if let err = error {
                print("Error fetching challenge detail: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    self.delegate?.fireManager?(self, didDownloadDays: docArray, type: dataType)
                }
            }
        }
    }
    
    func addNewRestaurant(newRestData: BasicInfo) {
        do {
            try fireDB.collection("Restaurant").document(newRestData.basicId).setData(from: newRestData)
            print("successfully added a new restaurant to firebase")
        } catch let err {
            print("Error writing restaurant to Firestore: \(err)")
        }
    }
    
    func uploadImage(
        toStorageWith restId: String,
        uniqueString: String,
        selectedImage: UIImage,
        nameOrDescribe: String,
        dataType: DataType) {
        let storageRef = Storage.storage().reference().child(dataType.name()).child(restId).child("\(uniqueString).png")
        let comprssedImage = selectedImage.jpegData(compressionQuality: 0.8)
        if let uploadData = comprssedImage {
            storageRef.putData(uploadData, metadata: nil) { _, error in
                if let err = error {
                    print("Error upload data: \(err)")
                }
                storageRef.downloadURL { (url, error) in
                    if let err = error {
                        print("Error getting image url: \(err)")
                    }
                    
                    if let uploadImageUrl = url?.absoluteString {
                        switch dataType {
                        case .comments:
                            self.addComment(toFirestoreWith: restId, userId: "Austin", describe: nameOrDescribe, image: uploadImageUrl)
                        case .menu:
                            self.addCuisine(toFirestoreWith: uploadImageUrl, restaurantId: restId, cuisineName: nameOrDescribe)
                        case .friends, .friendRequest, .challengeRequest, .owner, .challenger: break
                        }
                    }
                }
            }
        }
    }
    
    func addCuisine(toFirestoreWith urlString: String, restaurantId: String, cuisineName: String) {
        fireDB.collection("Restaurant").document(restaurantId).collection("menu").document(cuisineName).setData([
            "cuisineName": cuisineName,
            "describe": "",
            "image": urlString,
            "vote": "0"
        ]) { (error) in
            if let err = error {
                print("Error update menu: \(err)")
            } else {
                print("successfully updated menu")
                self.delegate?.fireManager?(self, didFinishUpdate: .menu)
            }
        }
    }
    
    func updateProfile(userId: String, newNickname: String, newDescribe: String, newEmoji: String) {
        fireDB.collection("User").document(userId).updateData([
            "nickname": newNickname,
            "describe": newDescribe,
            "emoji": newEmoji
        ]) { (error) in
            if let err = error {
                print("Error updating profile: \(err)")
            }
        }
    }
    
    func updateVote(restaurantId: String, cuisineName: String, newValue: Int) {
        fireDB.collection("Restaurant").document(restaurantId).collection("menu").document(cuisineName).updateData([
            "vote": newValue
        ]) { (error) in
            if let err = error {
                print("Error update vote: \(err)")
            } else {
                print("successfully updated vote, new value: \(newValue)")
                self.updateHotCuisine(restaurantId: restaurantId)
            }
        }
    }
    
    func updateHotCuisine(restaurantId: String) {
        fireDB.collection("Restaurant").document(restaurantId).collection("menu")
            .order(by: "vote", descending: true).limit(to: 2).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error calling order: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    self.fireDB.collection("Restaurant").document(restaurantId).updateData([
                        "hots": FieldValue.delete()
                    ])
                    for document in docArray {
                        self.fireDB.collection("Restaurant").document(restaurantId).updateData([
                            "hots": FieldValue.arrayUnion(["\(document.documentID)"])
                        ])
                    }
                }
            }
        }
    }
    
    func addChallenge(owner: String, title: String, describe: String, days: Int) {
        ref = fireDB.collection("Challenge").addDocument(data: [
            "challengeId": "",
            "days": days,
            "describe": describe,
            "owner": owner,
            "title": title,
            "updatedTime": FieldValue.serverTimestamp(),
            "vsChallengeId": ""
            ], completion: { (error) in
                if let err = error {
                    print("Error adding new challenge: \(err)")
                } else {
                    if let challengeId = self.ref?.documentID {
                        self.updateChallengeId(challengeId: challengeId, days: days)
                    }
                }
        })
    }
    
    func addDaysChallenge(days: Int, challengeId: String) {
        for index in 0 ..< days {
            fireDB.collection("Challenge").document(challengeId).collection("Days").document("\(index+1)").setData([
                "createdTime": FieldValue.serverTimestamp(),
                "describe": "",
                "image": "",
                "index": "\(index+1)",
                "title": "挑戰第\(index+1)天"
            ]) { (error) in
                if let err = error {
                    print("Error added every day challenge doc: \(err)")
                }
            }
        }
        print("========成功新增每日挑戰========")
    }
    
    func addComment(toFirestoreWith restaurantId: String, userId: String, describe: String, image: String) {
//        var ref: DocumentReference?
        ref = fireDB.collection("Restaurant").document(restaurantId).collection("comments").addDocument(data: [
            "userId": userId,
            "describe": describe,
            "date": FieldValue.serverTimestamp(),
            "image": image
        ]) { (error) in
            if let err = error {
                print("Error adding a new comment: \(err)")
            } else {
                if let commentId = self.ref?.documentID {
                    self.updateCommentId(restaurantId: restaurantId, commentId: commentId)
                    print("successfully added a new comment with ID: \(commentId)")
                }
            }
        }
    }
    
    func updateChallengeId(challengeId: String, days: Int) {
        fireDB.collection("Challenge").document(challengeId).updateData([
            "challengeId": challengeId
        ]) { (error) in
            if let err = error {
                print("Error updated challenge id: \(err)")
            } else {
                self.addDaysChallenge(days: days, challengeId: challengeId)
            }
        }
    }
    
    func updateCommentId(restaurantId: String, commentId: String) {
        fireDB.collection("Restaurant").document(restaurantId).collection("comments").document(commentId).updateData([
            "commentId": commentId
        ]) { (error) in
            if let err = error {
                print("Error updated comment ID: \(err).")
            } else {
                self.delegate?.fireManager?(self, didFinishUpdate: .comments)
            }
        }
    }
    
    func listener(dataType: DataType) {
        fireDB.collection("Restaurant").document().collection(dataType.name()).addSnapshotListener { (snapshot, error) in
            if let err = error {
                print("Error fetching document: \(err)")
            } else {
                if let data = snapshot {
                    print("listener fetched: \(data)")
                }
            }
        }
    }

}
