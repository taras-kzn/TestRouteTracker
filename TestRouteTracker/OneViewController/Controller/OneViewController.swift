//
//  OneViewController.swift
//  TestRouteTracker
//
//  Created by admin on 31.03.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift

class OneViewController: UIViewController {

    let realmService = RealmData()
    var marker: GMSMarker?
    var locationManager: CLLocationManager?
    var geocoder: CLGeocoder = CLGeocoder()
    var status = false
    var saveRoute: GMSPolyline?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
        actionButton.layer.cornerRadius = 15
    }
    
    func configureMap() {
        mapView.mapType = .hybrid
        mapView.addSubview(actionButton)
        mapView.delegate = self
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestLocation()
    }
    
    @IBAction func action(_ sender: UIButton) {
        if status {
            actionButton.setTitle("Start", for: .normal)
            locationManager?.stopUpdatingLocation()
            locationManager?.stopMonitoringSignificantLocationChanges()
            guard let stringPath = routePath?.encodedPath() else {return}
            realmService.saveRouteData(stringPath)
            route?.map = nil
            routePath?.removeAllCoordinates()
            status = false
        } else {
            actionButton.setTitle("Stop", for: .normal)
            saveRoute?.map = nil
            route?.map = nil
            route = GMSPolyline()
            route?.strokeWidth = 5
            routePath = GMSMutablePath()
            route?.map = mapView
            locationManager?.startUpdatingLocation()
            status = true
        }
    }
    
    func newAddMarker(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        marker.map = mapView
        mapView.animate(to: camera)
    }
    
    @IBAction func goHome(_ sender: UIButton) {
        if status == true {
            let ac = UIAlertController(title: "Cлежение активное на данный момент", message: "Необходимо остановить слижение", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: actionAlert)
            ac.addAction(action)
            present(ac, animated: true)
        } else {
            oldRoute()
        }
    }
    
    func actionAlert(action: UIAlertAction! = nil) {
        actionButton.setTitle("Start", for: .normal)
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringSignificantLocationChanges()
        guard let stringPath = routePath?.encodedPath() else {return}
        realmService.saveRouteData(stringPath)
        route?.map = nil
        routePath?.removeAllCoordinates()
        status = false
        oldRoute()
    }
    
    func oldRoute() {
        saveRoute?.map = nil
        saveRoute = GMSPolyline()
        saveRoute?.strokeWidth = 5
        guard let route = saveRoute else { return }
        realmService.loadRouteData(route: route)
        guard let count = route.path?.count() else {return}
        guard let one = route.path?.coordinate(at: 0) else {return}
        guard let two = route.path?.coordinate(at: count - 1) else {return}
        let bounds = GMSCoordinateBounds(coordinate: one, coordinate: two)
         let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
         mapView.animate(to: camera)
        route.map = mapView
    }
    
    func addMarker(position: CLLocationCoordinate2D, title: String, snipet: String) {
        let marker = GMSMarker(position: position)
        let camera = GMSCameraPosition.camera(withTarget: position, zoom: 17)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.title = title
        marker.snippet = snipet
        marker.map = mapView
        mapView.animate(to: camera)
        self.marker = marker
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func geocoderLocation(marker: GMSMarker, coordinate: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (places, error) in
            if let place = places?.first {
                marker.snippet = place.administrativeArea
                marker.title = place.country
            }
        }
    }
}

extension OneViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let manualMarker = marker {
            manualMarker.position = coordinate
            geocoderLocation(marker: manualMarker, coordinate: coordinate)
        } else {
            let marker = GMSMarker(position: coordinate)
            geocoderLocation(marker: marker, coordinate: coordinate)
            marker.map = mapView
            self.marker = marker
        }
    }
}

extension OneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        routePath?.add(location.coordinate)
        route?.path = routePath
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
