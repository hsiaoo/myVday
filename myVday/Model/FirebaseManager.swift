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
    @objc optional func fireManager(_ manager: FirebaseManager, fetchDoc: [String: Any])
    @objc optional func fireManager(_ manager: FirebaseManager, fetchSubCollection docArray: [QueryDocumentSnapshot], sub: SubCollection)
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

class FirebaseManager: NSObject {
    let fireDB = Firestore.firestore()
    let storageDB =  Storage.storage()
    var ref: DocumentReference?
    weak var delegate: FirebaseManagerDelegate?
    
    func fetchMainCollectionDoc(mainCollection: MainCollection, docId: String) {
        fireDB.collection(mainCollection.name()).document(docId).getDocument { (snapshot, _) in
            if let document = snapshot, document.exists, let docData = document.data() {
                self.delegate?.fireManager?(self, fetchDoc: docData)
            } else {
                print("======Document does not exist.======")
            }
        }
    }
    
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
    
    func fetchSubCollection(mainCollection: MainCollection, mainDocId: String, sub: SubCollection) {
        fireDB.collection(mainCollection.name()).document(mainDocId).collection(sub.name()).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    self.delegate?.fireManager?(self, fetchSubCollection: docArray, sub: sub)
//                    for document in docArray {
//                        print("\(document.documentID) => \(document.data())")
//                    }
                }
            }
        }
    }
    
    func fetchMyChallenge(ownerId: String) {
        fireDB.collection("Challenge").whereField("ownerId", isEqualTo: ownerId).getDocuments { (snapshot, error) in
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
            try fireDB.collection("Restaurant").document(newRestData.restaurantId).setData(from: newRestData)
            print("successfully added a new restaurant to firebase")
        } catch let err {
            print("Error writing restaurant to Firestore: \(err)")
        }
    }
    
//    func uploadImage(
//        toStorageWith restId: String,
//        uniqueString: String,
//        selectedImage: UIImage,
//        nameOrDescribe: String,
//        dataType: DataType) {
//        let storageRef = storageDB.reference().child(dataType.name()).child(restId).child("\(uniqueString).png")
//        let comprssedImage = selectedImage.jpegData(compressionQuality: 0.1)
//        if let uploadData = comprssedImage {
//            storageRef.putData(uploadData, metadata: nil) { _, error in
//                if let err = error {
//                    print("Error upload data: \(err)")
//                }
//                storageRef.downloadURL { (url, error) in
//                    if let err = error {
//                        print("Error getting image url: \(err)")
//                    }
//
//                    if let uploadImageUrl = url?.absoluteString {
//                        switch dataType {
//                        case .menu:
//                            self.addCuisine(imageString: uploadImageUrl, restaurantId: restId, cuisineName: nameOrDescribe)
//                        case .friends, .friendRequest, .challengeRequest, .owner, .challenger, .comments: break
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func uploadMenuChallengeImage(
        restaurantChallengeId: String,
        imageNameString: String,
        selectedImage: UIImage,
        dataType: ImageType,
        completion: @escaping (String) -> Void) {
        let storageRef = storageDB.reference().child(dataType.name()).child(restaurantChallengeId).child("\(imageNameString).png")
        let compressedImage = selectedImage.jpegData(compressionQuality: 0.1)
        if let uploadData = compressedImage {
            storageRef.putData(uploadData, metadata: nil) { (_, error) in
                if let err = error {
                    print("Error upload image: \(err)")
                } else {
                    storageRef.downloadURL { (imageUrl, error) in
                        if let err = error {
                            print("Error download image url: \(err)")
                        } else {
                            if let imageString = imageUrl?.absoluteString {
                                completion(imageString)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadProfileImage(
        userId: String,
        profileImage: UIImage,
        completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("user").child("\(userId).png")
        let comprssedImage = profileImage.jpegData(compressionQuality: 0.1)
        if let uploadData = comprssedImage {
            storageRef.putData(uploadData, metadata: nil) { _, error in
                if let err = error {
                    print("Error upload image: \(err)")
                } else {
                    storageRef.downloadURL { (imageUrl, error) in
                        if let err = error {
                            print("Error getting image url: \(err)")
                        } else {
                            if let imageString = imageUrl?.absoluteString {
                                completion(imageString)
                            }
                        }
                    }
                }
            }
        }
    }
        
    func addCuisine(imageString: String, restaurantId: String, cuisineName: String, completion: @escaping () -> Void) {
        fireDB.collection("Restaurant").document(restaurantId).collection("menu").document(cuisineName).setData([
            "cuisineName": cuisineName,
            "describe": "",
            "image": imageString,
            "vote": 0
        ]) { (error) in
            if let err = error {
                print("Error update menu: \(err)")
            } else {
                completion()
                print("======成功新增一道\(restaurantId)的餐點======")
            }
        }
    }
    
    //userId: String, newNickname: String, newDescribe: String, newEmoji: String
    //, fetchProfile: (String) -> Void
    func updateProfile(profileData: User) {
        fireDB.collection("User").document(profileData.userId).updateData([
            "nickname": profileData.nickname,
            "describe": profileData.describe,
            "emoji": profileData.emoji,
            "image": profileData.image
        ]) { (error) in
            if let err = error {
                print("Error updating profile: \(err)")
            } else {
                print("======成功更新使用者資料======")
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
    
    func addUser(loginUser: User) {
        do {
            try fireDB.collection("User").document(loginUser.userId).setData(from: loginUser)
            print("=======成功新增使用者=======")
        } catch let err {
            print("Error added user to Firestore: \(err)")
        }
    }
    
    func addChallenge(newChallenge: Challenge, friendId: String, ownerId: String, completion: @escaping () -> Void) {
        if newChallenge.challengeId.isEmpty {
            do {
                ref = try fireDB.collection("Challenge").addDocument(from: newChallenge, encoder: Firestore.Encoder(), completion: { (error) in
                    if let err = error {
                        print("Error added challenge: \(err)")
                    } else {
                        //產生挑戰ID流水編號，並回頭更新自己的挑戰challengeId
                        if let challengeId = self.ref?.documentID {
                            self.updateChallengeId(challengeId: challengeId, friendId: friendId, newChallenge: newChallenge)
                        }
                    }
                })
                completion()
            } catch let err {
                print("Error added challenge to Firestore: \(err)")
            }
        } else {
            //accepted challenge，自己的挑戰已有challengeId
            fireDB.collection("Challenge").document(newChallenge.challengeId).setData([
                "challengeId": newChallenge.challengeId,
                "ownerId": ownerId,
                "ownerName": newChallenge.ownerName,
                "title": newChallenge.title,
                "describe": newChallenge.describe,
                "days": newChallenge.days,
                "vsChallengeId": newChallenge.vsChallengeId,
                "updatedTime": FieldValue.serverTimestamp(),
                "daysCompleted": newChallenge.daysCompleted
            ]) { (error) in
                if let err = error {
                    print("Error added challenge to Firestore: \(err)")
                } else {
                    //拿自己的challengeId更新對方的vsChallengeId
                    self.updateChallengeId(challengeId: newChallenge.vsChallengeId, friendId: "", newChallenge: newChallenge)
                    completion()
                }
            }
        }
    }
    
    func addNewFriend(friendsOfUserId: String, newFriend: User) {
        do {
            try fireDB.collection("User").document(friendsOfUserId).collection("friends").document(newFriend.userId).setData(from: newFriend)
            print("======\(friendsOfUserId)成功新增朋友\(newFriend.nickname)======")
        } catch let err {
            print("Error added friend to Firestore: \(err)")
        }
    }
    
    func addFriendRequest(newFriendId: String, personalData: User, completion: @escaping () -> Void) {
        do {
            try fireDB.collection("User").document(newFriendId).collection("friendRequest").document(personalData.userId).setData(from: personalData)
            completion()
            print("======successfully sent a friend request to \(newFriendId)======")
        } catch let error {
            print("Error sent friend request: \(error)")
        }
    }
    
    func addChallengeRequest(newChallenge: Challenge, friendId: String, vsChallengeId: String, dataType: DataType) {
        ref = fireDB.collection("User").document(friendId).collection(dataType.name()).addDocument(data: [
            "challengeId": "",
            "days": newChallenge.days,
            "daysCompleted": 0,
            "describe": newChallenge.describe,
            "ownerId": newChallenge.ownerId,
            "ownerName": newChallenge.ownerName,
            "title": newChallenge.title,
            "updatedTime": FieldValue.serverTimestamp(),
            "vsChallengeId": vsChallengeId
            ], completion: { (error) in
                if let err = error {
                    print("Error added challenge request: \(err)")
                } else {
                    if let challengeId = self.ref?.documentID {
                        //更新challengeId
                        self.fireDB.collection("User").document(friendId).collection(dataType.name()).document(challengeId).updateData([
                            "challengeId": challengeId
                        ]) { (error) in
                            if let err = error {
                                print("Error updated challenge id: \(err)")
                            }
                        }
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
                "index": index + 1,
                "title": "挑戰第\(index+1)天"
            ]) { (error) in
                if let err = error {
                    print("Error added every day challenge doc: \(err)")
                }
            }
        }
    }
    
    func addComment(toFirestoreWith restaurantId: String, userId: String, nickname: String, comment: String, completion: @escaping () -> Void) {
        ref = fireDB.collection("Restaurant").document(restaurantId).collection("comments").addDocument(data: [
            "userId": userId,
            "name": nickname,
            "comment": comment,
            "date": FieldValue.serverTimestamp()
        ]) { (error) in
            if let err = error {
                print("Error adding a new comment: \(err)")
            } else {
                if let commentId = self.ref?.documentID {
                    self.updateCommentId(restaurantId: restaurantId, commentId: commentId)
                    completion()
                    print("successfully added a new comment with ID: \(commentId)")
                }
            }
        }
    }

    func updateChallengeId(challengeId: String, friendId: String, newChallenge: Challenge) {
        if newChallenge.challengeId.isEmpty {
            //更新自己的挑戰ID
            fireDB.collection("Challenge").document(challengeId).updateData([
                "challengeId": challengeId,
                "updatedTime": FieldValue.serverTimestamp()
            ]) { (error) in
                if let err = error {
                    print("Error updated challenge id: \(err)")
                } else {
                    self.addDaysChallenge(days: newChallenge.days, challengeId: challengeId)
                    if friendId.isEmpty {
                        return
                    } else {
                        //發出challenge request
                        self.addChallengeRequest(newChallenge: newChallenge, friendId: friendId, vsChallengeId: challengeId, dataType: .challengeRequest)
                    }
                }
            }
        } else {
            //更新挑戰發起者的vsChallengeId
            fireDB.collection("Challenge").document(challengeId).updateData([
                "vsChallengeId": newChallenge.challengeId
            ]) { (error) in
                if let err = error {
                    print("Error updated vsChallenged: \(err)")
                } else {
                    //替自己預先新增每日挑戰
                    self.addDaysChallenge(days: newChallenge.days, challengeId: newChallenge.challengeId)
                }
            }
        }
    }
    
    func updateDailyChallenge(challengeId: String, dayIndex: Int, title: String, newDescribe: String, oldDescribe: String, imageString: String, completedDays: Int) {
        fireDB.collection("Challenge").document(challengeId).collection("Days").document("\(dayIndex)").updateData([
            "title": title,
            "describe": newDescribe,
            "image": imageString
        ]) { (error) in
            if let err = error {
                print("Error updated daily challenge: \(err)")
            } else {
                //若describe有值，表示完成今日挑戰，要更新daysCompleted
                if newDescribe.isEmpty {
                    //如果此次修改後的describe為空，則不算完成挑戰
                    return
                } else {
                    //修改後的describe有值，而且先前的describe為空，代表完成今日挑戰
                    if oldDescribe.isEmpty {
                        self.fireDB.collection("Challenge").document(challengeId).updateData([
                            "daysCompleted": completedDays + 1
                        ]) { (error) in
                            if let err = error {
                                print("Error updated daysCompleted: \(err)")
                            }
                        }
                    } else {
                        //修改後的describe有值，但是先前的describe本來就有值，也不算挑戰成功
                        return
                    }
                }
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
//                self.delegate?.fireManager?(self, didFinishUpdate: .comments)
                print("======成功新增評論、更新評論ID======")
            }
        }
    }
    
    func deleteRequest(user: String, dataType: DataType, requestId: String) {
        fireDB.collection("User").document(user).collection(dataType.name()).document(requestId).delete { (error) in
            if let err = error {
                print("Error deleted document in request collection: \(err)")
            }
        }
    }
    
    func deleteSubCollectionDoc(mainCollection: MainCollection, mainDocId: String, sub: SubCollection, subDocId: String) {
        fireDB.collection(mainCollection.name()).document(mainDocId).collection(sub.name()).document(subDocId).delete { (error) in
            if let err = error {
                print("Error deleted certain document in \(sub.name()) sub collection: \(err)")
            } else {
                print("======successfully deleted a document in \(sub.name()) sub collection: \(subDocId)======")
            }
        }
    }
    
    func searchForNewFriend(nickname: String) {
        fireDB.collection("User").whereField("nickname", isEqualTo: nickname).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error searched new friend: \(err)")
            } else {
                if let docArray = snapshot?.documents {
                    self.delegate?.fireManager?(self, fetchSubCollection: docArray, sub: .friends)
//                    self.delegate?.fireManager?(self, didDownloadProfileDetail: docArray, type: .friends)
                }
            }
        }
    }
    
    func listener(dataType: DataType) {
        fireDB.collection("Restaurant").document().collection(dataType.name()).addSnapshotListener { snapshot, error in
                guard let document = snapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let newnew = document.documentChanges.map {$0.document.data()}
                print("======something new: \(newnew)======")
        }
    }
    
    func report(mainCollection: MainCollection, mainDocId: String, subCollection: SubCollection, reportedId: String, reportedData: Comments) {
        do {
            try fireDB.collection(mainCollection.name())
                .document(mainDocId)
                .collection(subCollection.name())
                .document(reportedId)
                .setData(from: reportedData)
            print("=====完成檢舉=====")
        } catch let error {
            fatalError("======Error: \(error)======")
        }
    }

}
