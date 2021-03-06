//
//  LocationManager.swift
//  TestRouteTracker
//
//  Created by admin on 29.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

final class LocationManager: NSObject {
    //MARK: - Properties
    static let instance = LocationManager()
    
    private let locationManager = CLLocationManager()
    let location: Variable<CLLocation?> = Variable(nil)
    //MARK: - init
    private override init() {
        super.init()
        configureLocationManager()
    }
    //MARK: - Functuions
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}
//MARK: - LocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location.value = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
