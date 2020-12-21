//
//  AddNewFriendVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/16.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AddNewFriendVC: UIViewController {

    @IBOutlet weak var newFriendSearchBar: UISearchBar!
    @IBOutlet weak var newFriendTableView: UITableView!
    
    let fireManager = FirebaseManager()
    var filterData = [User]()
    var alreadyFriend = [User]()
    var personalData: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        //fetch personal data
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            fireManager.fetchMainCollectionDoc(mainCollection: .user, docId: userId)
        }
    }
    
}

extension AddNewFriendVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let newFriendCell = tableView.dequeueReusableCell(
            withIdentifier: SearchForNewFriendTableViewCell.identifier,
            for: indexPath) as? SearchForNewFriendTableViewCell {
            if filterData.isEmpty {
                return newFriendCell
            } else {
                newFriendCell.newFriendNameLabel.text = filterData[indexPath.row].nickname
                newFriendCell.newFriendBtn.addTarget(self, action: #selector(sentFriendRequest(_:)), for: .touchUpInside)
                return newFriendCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func sentFriendRequest(_ sender: UIButton) {
        //should pop up a alert controller
        guard let personalData = personalData else { return }
        let tappedPoint = sender.convert(CGPoint.zero, to: newFriendTableView)
        if let indexPath = newFriendTableView.indexPathForRow(at: tappedPoint) {
            let targetFriend = filterData[indexPath.row]
            fireManager.addFriendRequest(newFriendId: targetFriend.userId, personalData: personalData)

            filterData.remove(at: indexPath.row)
            newFriendTableView.beginUpdates()
            newFriendTableView.deleteRows(at: [indexPath], with: .automatic)
            newFriendTableView.endUpdates()
        }
    }
}

extension AddNewFriendVC: UISearchBarDelegate {
    //start searching friend
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterData.removeAll()
        guard let nickname = newFriendSearchBar.text else { return }
        if nickname.isEmpty {
            print("寫好搜尋條件")
        } else {
            fireManager.searchForNewFriend(nickname: nickname)
        }
    }
}

extension AddNewFriendVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadProfileDetail data: [QueryDocumentSnapshot], type: DataType) {
        if type == .friends {
            filterData.removeAll()
            for document in data {
                let aUser = User(
                    userId: document["userId"] as? String ?? "no user id",
                    nickname: document["nickname"] as? String ?? "no nickname",
                    describe: document["describe"] as? String ?? "no describe",
                    emoji: document["emoji"] as? String ?? "no emoji",
                    image: document["image"] as? String ?? "no image")
                //檢查此User是否已經是自己的朋友，如果不是，就加入filterData陣列內準備顯示在畫面上
                let isFriend = alreadyFriend.contains { (user) -> Bool in
                    user.nickname == aUser.nickname
                }
                switch isFriend {
                case true:
                    newFriendTableView.reloadData()
                case false:
                    filterData.append(aUser)
                }
            }
            newFriendTableView.reloadData()
        }
    }
    
    func fireManager(_ manager: FirebaseManager, fetchDoc: [String: Any]) {
        personalData = User(
            userId: fetchDoc["userId"] as? String ?? "no user id",
            nickname: fetchDoc["nickname"] as? String ?? "no nickname",
            describe: fetchDoc["describe"] as? String ?? "no describe",
            emoji: fetchDoc["emoji"] as? String ?? "no emoji",
            image: fetchDoc["image"] as? String ?? "no image")
    }
}
