//
//  AddCuisineVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/4.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseStorage
//import FirebaseFirestore

class AddCuisineVC: UIViewController {

    @IBOutlet weak var cuisineNameTF: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    let fireManager = FirebaseManager()
    var restId: String?
    var selectedImage: UIImage?
    var imageString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addPhotoBtn(_ sender: UIBarButtonItem) {
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
    
    @IBAction func uploadNewCuisineBtn(_ sender: UIBarButtonItem) {
        
//        if let cuisineName = cuisineNameTF.text, let okImageString = imageString, let okRestaurantId = restId {
//            if cuisineName.isEmpty || selectedImage == nil {
//                print("======缺少餐點名稱或餐點照片======")
//            } else {
//                let newCuisine = Menu(cuisineName: cuisineName, describe: "", image: okImageString, vote: 0)
//                fireManager.addDocInSubCollection(mainCollection: .restaurant, mainDocId: okRestaurantId, subCollection: .menu, subDocId: newCuisine.cuisineName)
//
//            }
                    if let okCuisineName = cuisineNameTF.text, let okImageString = imageString, let okRestaurantId = restId {
                        if okCuisineName.isEmpty || selectedImage == nil {
                            print("======缺少餐點名稱或餐點照片======")
                        } else {
                            fireManager.addCuisine(
                                imageString: okImageString,
                                restaurantId: okRestaurantId,
                                cuisineName: okCuisineName)
                        }
                    }
            //        navigationController?.popViewController(animated: true)
        }
    }
    
extension AddCuisineVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cuisineNameTF.resignFirstResponder()
        return false
    }
}

extension AddCuisineVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
            photoImageView.image = selectedImage
        }
        dismiss(animated: true) {
            if let restaurantId = self.restId, let okImage = self.selectedImage {
                let uniqueString = NSUUID().uuidString
                self.fireManager.uploadMenuChallengeImage(
                    restaurantChallengeId: restaurantId,
                    imageNameString: uniqueString,
                    selectedImage: okImage,
                    dataType: .menu) { picImage in
                        self.imageString = picImage
                        print("======成功上傳餐點相片，image string: \(picImage)======")
                }
            }
        }
    }
}