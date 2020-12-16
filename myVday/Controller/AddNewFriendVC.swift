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
    let fireManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fireManager.delegate = self
    }
    
    @IBAction func tappedCloseNewFriendBtn(_ sender: Any) {
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
        print("送出好友邀請")
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
            for document in data {
                let aUser = User(
                    userId: document["userId"] as? String ?? "no user id",
                    nickname: document["nickname"] as? String ?? "no nickname",
                    describe: document["describe"] as? String ?? "no describe",
                    emoji: document["emoji"] as? String ?? "no emoji",
                    image: document["image"] as? String ?? "no image")
                filterData.append(aUser)
            }
            newFriendTableView.reloadData()
        }
    }
}
