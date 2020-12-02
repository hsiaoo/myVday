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

class MapVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var restaurantTableView: UITableView!
    let locationManager = CLLocationManager()
    let fireManager = FirebaseManager()
    var isFilter = false
    var basicInfos = [BasicInfo]()
    var comments = [Comments]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fireManager.delegate = self
        locationManager.delegate = self
        
        fireManager.fetchData()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func filterBtnClicked(_ sender: UIBarButtonItem) {
        isFilter = !isFilter
        if isFilter == true {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 1,
                delay: 0,
                options: .curveEaseIn,
                animations: {
                    self.filterView.frame = CGRect(x: 0, y: 88, width: UIScreen.main.bounds.width, height: 180)
            },
                completion: nil)
        } else {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 1,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.filterView.frame = CGRect(x: 0, y: -93, width: UIScreen.main.bounds.width, height: 180)
            },
                completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailSegue" {
            let detailVC = segue.destination as? DetailRestaurantVC
            detailVC?.basicInfo = sender as? BasicInfo
//            if let okInfo = sender as? BasicInfo {
//                detailVC?.settingInfo(basicInfo: okInfo)
//            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //使用者實際目前所在位置
        guard let location = locations.first else { return }
        
        //測試用的座標，忠孝敦化站
//        let lat = 25.041457
//        let lng = 121.550687
//        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        mapView.camera = GMSCameraPosition(
            //使用者目前位置的座標
            target: location.coordinate,
            
            //測試用的座標
            //target: coordinates,
            zoom: 15,
            bearing: 0,
            viewingAngle: 0)
    }
    
    func placeMarker(position: CLLocationCoordinate2D, title: String) {
        let marker = GMSMarker()
        marker.position = position
        marker.title = title
        marker.map = mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error: \(error)")
    }
    
}//end of class MapResultesVC

extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        basicInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let resultsCell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as? MapTableViewCell {
            resultsCell.titleLabel.text = basicInfos[indexPath.row].name
            resultsCell.addressLabel.text = basicInfos[indexPath.row].address
            resultsCell.hot1Label.text = basicInfos[indexPath.row].hots[0]
            resultsCell.hot2Label.text = basicInfos[indexPath.row].hots[1]
            resultsCell.tag1Label.text = basicInfos[indexPath.row].hashtags[0]
            resultsCell.tag2Label.text = basicInfos[indexPath.row].hashtags[1]
            return resultsCell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataToDetail = basicInfos[indexPath.row]
        performSegue(withIdentifier: "toDetailSegue", sender: dataToDetail)
    }
}

extension MapVC: FirebaseManagerDelegate {
    
    func fireManager(_ manager: FirebaseManager, didDownload basicData: [QueryDocumentSnapshot]) {
        for document in basicData {
            let newInfo = BasicInfo(
                address: document["address"] as? String ?? "no address",
                describe: document["describe"] as? String ?? "no describe",
                hashtags: document["hashtags"] as? [String] ?? [""],
                hots: document["hots"] as? [String] ?? [""],
                hours: document["hours"] as? [String: String] ?? ["": ""],
                basicId: document["id"] as? String ?? "no id",
                latitude: document["latitude"] as? Double ?? 0.0,
                longitude: document["longitude"] as? Double ?? 0.0,
                name: document["name"] as? String ?? "no name",
                phone: document["phone"] as? String ?? "no phone number")
            self.placeMarker(position: CLLocationCoordinate2D(latitude: newInfo.latitude, longitude: newInfo.longitude), title: newInfo.name)
            basicInfos.append(newInfo)
        }
        restaurantTableView.reloadData()
    }
    
//    func fireManager(_ manager: FirebaseManager, didDownload detailData: [QueryDocumentSnapshot], type: DataType) {
//        switch type {
//        case .comments:
//            for document in detailData {
//                let newComment = Comments(
//                    userId: document["userId"] as? String ?? "no user id",
//                    describe: document["describe"] as? String ?? "no describe",
//                    date: document["date"] as? String ?? "no date")
//                comments.append(newComment)
//            }
//        case .menu:
//            print("==========menuuuuu===========")
//        }
//    }
    
}
