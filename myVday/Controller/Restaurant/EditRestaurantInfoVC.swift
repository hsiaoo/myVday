//
//  EditRestaurantInfoVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2021/2/24.
//  Copyright © 2021 H.W. Hsiao. All rights reserved.
//

import UIKit

class EditRestaurantInfoVC: UIViewController {

    var restaurantInfo: BasicInfo?
    let dayArray = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

extension EditRestaurantInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        case 3: return 7
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let information = restaurantInfo else { return UITableViewCell() }
        switch indexPath.section {
        case 0:
            if let nameAddressCell = tableView.dequeueReusableCell(
                withIdentifier: NameAddressTableViewCell.identifier,
                for: indexPath) as? NameAddressTableViewCell {
                nameAddressCell.nameLabel.text = information.name
                nameAddressCell.addressLabel.text = information.address
                return nameAddressCell
            }
        case 1:
            if let phoneCell = tableView.dequeueReusableCell(
                withIdentifier: PhoneTableViewCell.identifier,
                for: indexPath) as? PhoneTableViewCell {
                phoneCell.numberTextField.text = information.phone
                return phoneCell
            }
        case 2:
            if let hashtagsCell = tableView.dequeueReusableCell(
                withIdentifier: HashtagsTableViewCell.identifier,
                for: indexPath) as? HashtagsTableViewCell {
                
                return hashtagsCell
            }
        case 3:
            if let workingHourCell = tableView.dequeueReusableCell(
                withIdentifier: WorkingHourTableViewCell.identifier,
                for: indexPath) as? WorkingHourTableViewCell {

                workingHourCell.dayLabel.text = dayArray[indexPath.row]
                
                if information.hours.isEmpty {
                    
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"

                    let dateString = information.hours[indexPath.row]
                    let beginIndex = dateString.index(dateString.startIndex, offsetBy: 3)
                    let endIndex = dateString.index(dateString.endIndex, offsetBy: -4)
                    let range = beginIndex..<endIndex
                    let beginHourString = String(dateString[range])
                    let beginHourDate = dateFormatter.date(from: beginHourString) ?? Date()
                    
                    let endHourString = String(dateString.suffix(5))
                    let endHourDate = dateFormatter.date(from: endHourString) ?? Date()
                    
                    workingHourCell.fromHourPicker.setDate(beginHourDate, animated: true)
                    workingHourCell.toHourPicker.setDate(endHourDate, animated: true)
                }
                return workingHourCell
            }
        default: break
        }
        return UITableViewCell()
    }
    
}
