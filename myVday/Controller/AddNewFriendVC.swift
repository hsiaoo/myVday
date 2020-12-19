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
    
    var filterData = [User]()
    var alreadyFriend = [User]()
    var personalData: User?
    let fireManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fireManager.delegate = self
        fireManager.fetchProfileData(userId: "Austin")
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
                newFriendCell.newFriendNameLabel.text = filterData[indexPath.row].userId
                newFriendCell.newFriendBtn.addTarget(self, action: #selector(sentFriendRequest(_:)), for: .touchUpInside)
                return newFriendCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func sentFriendRequest(_ sender: UIButton) {
        print("已送出好友邀請")//shout pop up a alert controller
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterData.removeAll()
        guard let name = newFriendSearchBar.text else { return }
        if name.isEmpty {
            print("寫好搜尋條件")
        } else {
            fireManager.searchForNewFriend(name: name)
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
                    user.userId == aUser.userId
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
    
    func fireManager(_ manager: FirebaseManager, didDownloadProfile data: [String: Any]) {
        personalData = User(
            userId: data["userId"] as? String ?? "no user id",
            nickname: data["nickname"] as? String ?? "no nickname",
            describe: data["describe"] as? String ?? "no describe",
            emoji: data["emoji"] as? String ?? "no emoji",
            image: data["image"] as? String ?? "no image")
    }
}
