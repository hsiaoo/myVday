//
//  FriendChallengeListVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/9.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit

class FriendChallengeListVC: UIViewController {
    
    
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var notificationBtn: UIButton!
    
    var isFriendList = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listSetting()
    }
    
    @IBAction func tappedNotiBtn(_ sender: Any) {
    }
    
    func listSetting() {
        if isFriendList == true {
            listNameLabel.text = "朋友們"
        } else {
            listNameLabel.text = "挑戰們"
        }
    }
    
}

extension FriendChallengeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let friendChallengeCell = tableView.dequeueReusableCell(
            withIdentifier: FriendChallengeListTableViewCell.identifier,
            for: indexPath) as? FriendChallengeListTableViewCell {
            return friendChallengeCell
        } else {
            return UITableViewCell()            
        }
    }
    
}
