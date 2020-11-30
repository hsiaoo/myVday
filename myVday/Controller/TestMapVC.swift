//
//  TestMapVC.swift
//  myVday
//
//  Created by H.W. Hsiao on 2020/11/29.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps

class TestMapVC: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            locationManager.requestAlwaysAuthorization()
        }

        locationManager.startUpdatingLocation()
    }
    
}
    
    // MARK: - CLLocationManagerDelegate
    //1
    extension TestMapVC: CLLocationManagerDelegate {
      // 2
      func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
      ) {
        // 3
        guard status == .authorizedWhenInUse else {
          return
        }
        // 4
        locationManager.requestLocation()

        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
      }

      // 6
      func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
          return
        }

        // 7
        mapView.camera = GMSCameraPosition(
          target: location.coordinate,
          zoom: 15,
          bearing: 0,
          viewingAngle: 0)
      }

      // 8
      func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
      ) {
        print(error)
      }
    }
