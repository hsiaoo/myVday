//
//  AddCuisineVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/12/4.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseStorage

class AddCuisineVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var cuisineNameTF: UITextField!
    let fireManager = FirebaseManager()
    var restId: String? = nil
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addPhotoBtn(_ sender: UIButton) {
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
    
    @IBAction func uploadBtn(_ sender: Any) {
        guard let cuisineName = cuisineNameTF.text,
            let selectedImage = selectedImage
            else { return }
        if cuisineName.isEmpty {
            return
        } else {
            let uniqueString = NSUUID().uuidString
            if let restId = restId {
                fireManager.uploadCuisineImage(
                    toStorageWith: restId,
                    uniqueString: uniqueString,
                    selectedImage: selectedImage,
                    cuisineName: cuisineName)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
            photoImageView.image = selectedImage
            photoBtn.isEnabled = false
            photoBtn.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddCuisineVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cuisineNameTF.resignFirstResponder()
        return false
    }
}
