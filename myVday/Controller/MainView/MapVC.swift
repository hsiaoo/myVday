//
//  MapVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/26.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreLocation
import GoogleMaps
import MapKit

enum RestaurantStatus {
    case success, fail
}

class MapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var newRestView: UIView!
    @IBOutlet weak var newRestNameTF: UITextField!
    @IBOutlet weak var newRestAddressTF: UITextField!
    @IBOutlet weak var newRestBottomConstraint: NSLayoutConstraint!
    
    let fireManager = FirebaseManager()
    let mapManager = MapManager()
    var locationManager = CLLocationManager()
    var isFilter = false
    var basicInfos = [BasicInfo]()
    
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    let maxxX = UIScreen.main.bounds.maxX
    let maxxY = UIScreen.main.bounds.maxY
    
    private var infoWindow = MapInfoWindow()
    fileprivate var locationMarker: GMSMarker? = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        fireManager.delegate = self
        locationManager.delegate = self
        mapManager.delegate = self
        newRestBottomConstraint.constant = screenHeight
        self.infoWindow = loadNib()
        keyboardHandling()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailSegue" {
            let detailVC = segue.destination as? DetailRestaurantVC
            detailVC?.basicInfo = sender as? BasicInfo
        }
    }

    @IBAction func closeNewRestView(_ sender: UIBarButtonItem) {
        newRestBottomConstraint.constant = screenHeight
        navigationController?.navigationBar.isHidden = true
        
        //動畫有點僵硬，優化專案時再做
//        UIViewPropertyAnimator.runningPropertyAnimator(
//            withDuration: 1,
//            delay: 0,
//            options: .autoreverse,
//            animations: {
//                self.newRestView.frame = CGRect(x: 0, y: self.maxxY, width: self.screenWidth, height: 0)
//                self.navigationController?.navigationBar.frame = CGRect(x: 0, y: -100, width: 0, height: 0)
//        },
//            completion: nil)
    }
    
    @IBAction func saveNewRestBtn(_ sender: UIBarButtonItem) {
        guard let newRestAddress = newRestAddressTF.text, let newRestName = newRestNameTF.text else { return }
        if newRestName.isEmpty || newRestAddress.isEmpty {
            newRestaurantAlert(status: .fail, title: "😶", message: "請填入新餐廳的名稱及地址")
        } else {
            mapManager.addressToCoordinate(newRestName: newRestName, newRestAddress: newRestAddress)
            newRestNameTF.resignFirstResponder()
            newRestAddressTF.resignFirstResponder()
            newRestBottomConstraint.constant = screenHeight
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    @IBAction func changeSearchingRange() {
        //優化項目
        let newCoordinate = mapView.projection.coordinate(for: mapView.center)
        print("map view center coordinate: \(newCoordinate)")
        fireManager.fetchData(current: CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude))
    }
    
    func moveAddingRestViewUp() {
        infoWindow.removeFromSuperview()
        newRestBottomConstraint.constant = 0
//        navigationController?.navigationBar.isHidden = false
        
        //動畫有點僵硬，優化專案時再做
//        UIViewPropertyAnimator.runningPropertyAnimator(
//            withDuration: 1,
//            delay: 0,
//            options: .autoreverse,
//            animations: {
//                self.newRestView.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
//                self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 100, width: 100, height: 100)
//        },
//            completion: nil)
    }
    
    func newRestaurantAlert(status: RestaurantStatus, title: String, message: String) {
        let newRestaurantAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let promptAction = UIAlertAction(title: "確定", style: .default) { _ in
            switch status {
            case .success: break
            case .fail: break
            }
        }
        newRestaurantAlertController.addAction(promptAction)
        present(newRestaurantAlertController, animated: true, completion: nil)
    }
    
     func keyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
     }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //使用者實際目前所在位置
        guard let location = locations.first else { return }
        print("current location: \(location)")
        fireManager.fetchData(current: location)
        
        //        mapView.camera = GMSCameraPosition(
        //            //使用者目前位置的座標
        //            target: location.coordinate,
        //            zoom: 15,
        //            bearing: 20,
        //            viewingAngle: 45)
        mapView.animate(toLocation: location.coordinate)
        mapView.animate(toZoom: 15)
        mapView.animate(toBearing: 20)
        mapView.animate(toViewingAngle: 45)
        
        locationManager.stopUpdatingLocation()
    }
    
    func loadNib() -> MapInfoWindow {
        if let infoWindow = MapInfoWindow.instanceFromNib() as? MapInfoWindow {
            return infoWindow
        } else {
            return MapInfoWindow()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var markerData: BasicInfo?
        if let data = marker.userData as? BasicInfo {
            markerData = data
        }
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNib()
        guard let location = locationMarker?.position else {
            print("location not found")
            return false
        }
        
        infoWindow.spotData = markerData
        infoWindow.delegate = self
        
        infoWindow.layer.cornerRadius = 10
        infoWindow.layer.masksToBounds = true
        infoWindow.layer.borderWidth = 1.5
        infoWindow.layer.borderColor = UIColor.black.cgColor
        
        infoWindow.restaurantName.text = markerData?.name
        infoWindow.address.text = markerData?.address
        infoWindow.hotCuisineFirst.text = markerData?.hots[0]
        infoWindow.hotCuisineSecond.text = markerData?.hots[1]
        infoWindow.tagFirst.text = markerData?.hashtags[0]
        infoWindow.tagSecond.text = markerData?.hashtags[1]
        
        //offset the info window
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y -= 110
        self.view.addSubview(infoWindow)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //reposition infoWindow to stay on top of the marker
        if locationMarker != nil {
            guard let location = locationMarker?.position else {
                print("location not found.")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y -= 110
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //dismiss the infoWindow when user tapped somewhere else
        infoWindow.removeFromSuperview()
    }
    
    func placeMarker(position: CLLocationCoordinate2D, title: String, data: BasicInfo) {
//        mapView.clear()
        let marker = GMSMarker()
        
        marker.position = position
        marker.icon = UIImage(named: "redmarker64.png")
        marker.map = mapView
        marker.userData = data
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error: \(error)")
    }
    
}//end of class MapResultesVC

extension MapVC: MapInfoWindowDelegate {
    func didTapInfoButton(data: BasicInfo) {
        performSegue(withIdentifier: "toDetailSegue", sender: data)
    }
}

extension MapVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newRestNameTF.resignFirstResponder()
        newRestAddressTF.resignFirstResponder()
        return false
    }
}

extension MapVC: MapManagerDelegate {
    func mapManager(_ manager: MapManager, didGetCoordinate: CLPlacemark, name: String, address: String) {
        if let coordinate = didGetCoordinate.location?.coordinate {
            let newRestaurant = BasicInfo(
                address: address,
                describe: "",
                hashtags: ["", ""],
                hots: ["", ""],
                hours: ["", "", "", "", "", "", ""],
                restaurantId: name,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                name: name,
                phone: "")
            fireManager.addNewRestaurant(newRestData: newRestaurant)
        }
    }
}

extension MapVC: FirebaseManagerDelegate {
    func fireManager(_ manager: FirebaseManager, didDownloadBasic filteredArray: [QueryDocumentSnapshot]) {
        for document in filteredArray {
            let newInfo = BasicInfo(
                address: document["address"] as? String ?? "no address",
                describe: document["describe"] as? String ?? "no describe",
                hashtags: document["hashtags"] as? [String] ?? [""],
                hots: document["hots"] as? [String] ?? [""],
                hours: document["hours"] as? [String] ?? [""],
                restaurantId: document["restaurantId"] as? String ?? "no id",
                latitude: document["latitude"] as? Double ?? 0.0,
                longitude: document["longitude"] as? Double ?? 0.0,
                name: document["name"] as? String ?? "no name",
                phone: document["phone"] as? String ?? "no phone number")
            self.placeMarker(
                position: CLLocationCoordinate2D(latitude: newInfo.latitude, longitude: newInfo.longitude),
                title: newInfo.name,
                data: newInfo)
            basicInfos.append(newInfo)
        }
    }
}
