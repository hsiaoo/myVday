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
    
    let firebaseManager = FirebaseManager.instance
    var filterData = [User]()
    var alreadyFriend = [User]()
    var personalData: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firebaseManager.delegate = self
        
        //fetch personal data
        if let userId = UserDefaults.standard.string(forKey: "appleUserIDCredential") {
            firebaseManager.fetchMainCollectionDoc(mainCollection: .user, docId: userId)
        }
    }
    
    func newFriendAlert(title: String, message: String) {
        let alterController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let promptAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alterController.addAction(promptAction)
        present(alterController, animated: true, completion: nil)
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
                let newFriend = filterData[indexPath.row]
                newFriendCell.setUpNewFriendCell(with: newFriend)
                newFriendCell.newFriendBtn.addTarget(self, action: #selector(sentFriendRequest(_:)), for: .touchUpInside)
                return newFriendCell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func sentFriendRequest(_ sender: UIButton) {
        guard let personalData = personalData else { return }
        let tappedPoint = sender.convert(CGPoint.zero, to: newFriendTableView)
        if let indexPath = newFriendTableView.indexPathForRow(at: tappedPoint) {
            let targetFriend = filterData[indexPath.row]
            firebaseManager.addFriendRequest(newFriendId: targetFriend.userId, personalData: personalData) {
                self.filterData.remove(at: indexPath.row)
                self.newFriendTableView.beginUpdates()
                self.newFriendTableView.deleteRows(at: [indexPath], with: .automatic)
                self.newFriendTableView.endUpdates()
                self.newFriendAlert(title: "📬成功送出好友邀請！", message: "等待對方接受囉")
            }

        }
    }
}

extension AddNewFriendVC: UISearchBarDelegate {
    //start searching friend
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterData.removeAll()
        guard let nickname = newFriendSearchBar.text else { return }
        if nickname.isEmpty {
            newFriendAlert(title: "😶", message: "請填好搜尋條件")
        } else {
            firebaseManager.searchForNewFriend(nickname: nickname)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //使用者清空搜尋列的文字後，要清除下方table view內容
        if searchText.isEmpty {
            filterData.removeAll()
            newFriendTableView.reloadData()
        }
    }
    
}

extension AddNewFriendVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, fetchSubCollection docArray: [QueryDocumentSnapshot], sub: SubCollection) {
        if sub == .friends {
            if docArray.isEmpty {
                self.newFriendAlert(title: "🧐", message: "找不到這個人")
            } else {
                filterData.removeAll()
                for document in docArray {
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
