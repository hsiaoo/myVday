//
//  AddNewChallengeVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/13.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AddNewChallengeVC: UIViewController {
    
    @IBOutlet weak var challengeTitleTF: UITextField!
    @IBOutlet weak var challengeDescribeTF: UITextField!
    @IBOutlet weak var challengeDaysTF: UITextField!
    @IBOutlet weak var challengeFriendTF: UITextField!
    
    let testName = ["Bella", "Nina", "Tina"]
    let fireManager = FirebaseManager()
    var didAddedChallenge: (() -> Void)!
    var friendTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 450), style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        challengeTitleTF.becomeFirstResponder()
        challengeFriendTF.inputView = friendTableView
        tableViewSetting()
        
    }
    
    @IBAction func tappedCloseViewBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedDoneBtn(_ sender: Any) {
        guard let title = challengeTitleTF.text,
            let describe = challengeDescribeTF.text,
            let daysString = challengeDaysTF.text,
            let friendName = challengeFriendTF.text else { return }
        
        if title.isEmpty || describe.isEmpty || daysString.isEmpty {
            print("要填完")
        } else {
            if friendName.isEmpty {
                //單人挑戰
                let daysInt = Int(daysString) ?? 0
                if daysInt == 0 {
                    print("填好挑戰天數")
                } else {
                    fireManager.addChallenge(owner: "Austin", title: title, describe: describe, days: daysInt)
                    dismiss(animated: true) {
                        self.didAddedChallenge()
                    }
                }
            } else {
                //雙人挑戰
            }
        }
    }
    
}

extension AddNewChallengeVC: UITableViewDelegate, UITableViewDataSource {
    func tableViewSetting() {
        friendTableView.delegate = self
        friendTableView.dataSource = self
        friendTableView.register(ChallengeWithFriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let friendCell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? ChallengeWithFriendTableViewCell {
            friendCell.friendNameLabel.text = testName[indexPath.row]
//            let friendNameLabel = UILabel(frame: CGRect(x: 25.0, y: 8.0, width: 100.0, height: 30.0))
//            friendNameLabel.text = testName[indexPath.row]
//            friendCell.contentView.addSubview(friendNameLabel)

            friendCell.selectionStyle = .none
            return friendCell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendName = testName[indexPath.row]
        challengeFriendTF.text = friendName
    }
    
}

extension AddNewChallengeVC: FirebaseManagerDelegate {
    
}
