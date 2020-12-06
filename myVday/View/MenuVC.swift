//
//  MenuVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/1.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import Firebase

class MenuVC: UIViewController {

    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var grayMaskView: UIView!
    @IBOutlet weak var newCuisineView: UIView!
    @IBOutlet weak var newCuisineImage: UIImageView!
    @IBOutlet weak var newCuisineNameTF: UITextField!
    @IBOutlet weak var newCuisineBtn: UIButton!
    @IBOutlet weak var newCuisineViewTopConstraint: NSLayoutConstraint!
    
    let fireManager = FirebaseManager()
    var restaurantId: String? = ""
    var restaurantMenu = [Menu]()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireManager.delegate = self
        if let restId = restaurantId {
            fireManager.fetchSubCollections(restaurantId: restId, type: .menu)
        }
    }
    
    @IBAction func addCuisineBarBtn(_ sender: Any) {
//        if let addCuisineVC = storyboard?.instantiateViewController(identifier: "addCuisine") as? AddCuisineVC {
//            addCuisineVC.modalPresentationStyle = .custom
//            addCuisineVC.restId = restaurantId
//            present(addCuisineVC, animated: true, completion: nil)
//        }
        
        let navigationBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 88
        grayMaskView.isHidden = false
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1,
            delay: 0,
            options: .allowAnimatedContent,
            animations: {
                self.newCuisineView.frame = CGRect(x: 0, y: navigationBarHeight + 44, width: UIScreen.main.bounds.width, height: 415)
                self.grayMaskView.isHidden = false
        },
            completion: nil)
        newCuisineViewTopConstraint.constant = 0
    }
    
    @IBAction func addNewImageBtn(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "上傳照片", message: "請選擇照片來源", preferredStyle: .actionSheet)
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCamaraAction = UIAlertAction(title: "相機", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCamaraAction)
        imagePickerAlertController.addAction(cancelAction)
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelNewCuisine(_ sender: Any) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .allowAnimatedContent,
            animations: {
                self.newCuisineView.frame = CGRect(x: 0, y: -415, width: UIScreen.main.bounds.width, height: 415)
                self.grayMaskView.isHidden = true
        },
            completion: nil)
//        newCuisineViewTopConstraint.constant = -415
    }
    
    @IBAction func uploadNewCuisine(_ sender: Any) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .allowAnimatedContent,
            animations: {
                self.newCuisineView.frame = CGRect(x: 0, y: -300, width: UIScreen.main.bounds.width, height: 415)
                self.grayMaskView.isHidden = true
        },
            completion: nil)
        newCuisineViewTopConstraint.constant = -415
        
        guard let cuisineName = newCuisineNameTF.text,
            let selectedImage = selectedImage
            else { return }
        if cuisineName.isEmpty {
            return
        } else {
            let uniqueString = NSUUID().uuidString
            if let restId = restaurantId {
                fireManager.uploadImage(
                    toStorageWith: restId,
                    uniqueString: uniqueString,
                    selectedImage: selectedImage,
                    nameOrDescribe: cuisineName,
                    dataType: .menu)
            }
        }
        newCuisineImage.image = nil
        newCuisineNameTF.text = ""
        newCuisineBtn.isHidden = false
    }
}

extension MenuVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        restaurantMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let menuCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MenuCollectionViewCell.identifier,
            for: indexPath
            ) as? MenuCollectionViewCell {
            menuCell.activityIndicator.isHidden = false
            menuCell.activityIndicator.startAnimating()
            menuCell.cuisineName.text = restaurantMenu[indexPath.row].cuisineName
            
            if let imageUrl = URL(string: "\(restaurantMenu[indexPath.row].image)") {
                URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                    if let err = error {
                        print("Error getting image:\(err)")
                    }
                    if let okData = data {
                        DispatchQueue.main.async {
                            menuCell.imageView.image = UIImage(data: okData)
                            menuCell.activityIndicator.stopAnimating()
                            menuCell.activityIndicator.isHidden = true
                        }
                    }
                }.resume()
            }
            return menuCell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension MenuVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let sizeWidth = (screenWidth - 16 * 3) / 2
        return CGSize(width: sizeWidth, height: sizeWidth)
    }
}

extension MenuVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
            newCuisineImage.image = selectedImage
            newCuisineBtn.isEnabled = false
            newCuisineBtn.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
}

extension MenuVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newCuisineNameTF.resignFirstResponder()
        return false
    }
}

extension MenuVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadDetail data: [QueryDocumentSnapshot], type: DataType) {
        for menu in data {
            let newCuisine = Menu(
                cuisineName: menu["cuisineName"] as? String ?? "no cuisine name",
                describe: menu["describe"] as? String ?? "no describe",
                image: menu["image"] as? String ?? "no image")
            restaurantMenu.append(newCuisine)
        }
        menuCollectionView.reloadData()
    }
    
    func fireManager(_ manager: FirebaseManager, didFinishUpdate menuOrComment: DataType) {
        restaurantMenu.removeAll()
        if let restId = restaurantId {
            fireManager.fetchSubCollections(restaurantId: restId, type: menuOrComment)
        }
        menuCollectionView.reloadData()
    }
//    func fireManager(didFinishUpdate: FirebaseManager) {
//        restaurantMenu.removeAll()
//        if let restId = restaurantId {
//            fireManager.fetchSubCollections(restaurantId: restId, type: .menu)
//        }
//        menuCollectionView.reloadData()
//    }
}
