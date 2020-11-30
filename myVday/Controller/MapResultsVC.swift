//
//  MapResultsVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/26.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapResultsVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    var isFilter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
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
            _ = segue.destination as? DetailRestaurantVC
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
        
        //加上標記
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 25.042998, longitude: 121.562836)
        marker.title = "草蔬宴"
        marker.snippet = "義式蔬食餐廳"
        marker.map = mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error: \(error)")
    }
    
}//end of class MapResultesVC

extension MapResultsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let resultsCell = tableView.dequeueReusableCell(withIdentifier: "resultsCell", for: indexPath) as? MapResultsTableViewCell {
            return resultsCell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailSegue", sender: nil)
    }
}
