//
//  myVdayTests.swift
//  myVdayTests
//
//  Created by H.W. Hsiao on 2020/12/31.
//  Copyright © 2020 H.W. Hsiao. All rights reserved.
//

import XCTest
import CoreLocation
@testable import myVday

class MyVdayTests: XCTestCase {
    
    let mapManager = MapManager()
    let correctCoordinate = CLLocationCoordinate2D(latitude: 25.042175, longitude: 121.563327)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
//        let correctAddress = "台北市信義區忠孝東路四段553巷6弄12號"
//        mapManager.addressToCoordinate(newRestName: "vegan", newRestAddress: correctAddress)

        let wrongAddress = "台北市信義區忠孝東路四段553巷6弄20號"
        mapManager.addressToCoordinate(newRestName: "素食自助餐", newRestAddress: wrongAddress)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension MyVdayTests: MapManagerDelegate {
    func mapManager(_ manager: MapManager, didGetCoordinate: CLPlacemark, name: String, address: String) {
        if let coordinate = didGetCoordinate.location?.coordinate {
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            
//            XCTAssertEqual(latitude, correctCoordinate.latitude)
//            XCTAssertEqual(longitude, correctCoordinate.longitude)
            
            XCTAssertNotEqual(latitude, correctCoordinate.latitude)
            XCTAssertNotEqual(longitude, correctCoordinate.longitude)
            
        }
    }
}
