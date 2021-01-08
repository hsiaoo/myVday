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
//import MapKit

class MapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let fireManager = FirebaseManager()
    var locationManager = CLLocationManager()
    var basicInfos = [BasicInfo]()
    private var infoWindow = MapInfoWindow()
    fileprivate var locationMarker: GMSMarker? = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        fireManager.delegate = self
        locationManager.delegate = self
        self.infoWindow = loadNib()
        
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
        } else if segue.identifier == "newRestaurantSegue" {
            _ = segue.destination as? NewRestaurantVC
        }
    }
    
    @IBAction func changeSearchingRange() {
        //優化項目
        let newCoordinate = mapView.projection.coordinate(for: mapView.center)
        print("map view center coordinate: \(newCoordinate)")
        fireManager.fetchNearbyRestaurant(current: CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude))
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
        fireManager.fetchNearbyRestaurant(current: location)
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
    
}

extension MapVC: MapInfoWindowDelegate {
    func tappedInfoWindow(data: BasicInfo) {
        performSegue(withIdentifier: "toDetailSegue", sender: data)
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
