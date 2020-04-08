//
//  OneViewController.swift
//  TestRouteTracker
//
//  Created by admin on 31.03.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import GoogleMaps

class OneViewController: UIViewController {
    
    let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    var newCoordinate: CLLocationCoordinate2D?
    var titleMarker: String?
    var snipetMarker: String?
    var marker: GMSMarker?
    var manualMarker: GMSMarker?
    var locationManager: CLLocationManager?
    var geocoder: CLGeocoder = CLGeocoder()
    var status = false
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
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.mapType = .hybrid
        mapView.camera = camera
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
            status = false
        } else {
            actionButton.setTitle("Stop", for: .normal)
            route?.map = nil
            route = GMSPolyline()
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
        locationManager?.startUpdatingLocation()
        guard let title = titleMarker else {return}
        guard let snipet = snipetMarker else {return}
        if let cordinat = newCoordinate {
            mapView.animate(toLocation: cordinat)
            addMarker(position: cordinat, title: title, snipet: snipet)
        } else {
            mapView.animate(toLocation: coordinate)
            addMarker(position: coordinate, title: title, snipet: snipet)
        }
        
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
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
            geocoderLocation(marker: manualMarker, coordinate: coordinate)
        } else {
            let marker = GMSMarker(position: coordinate)
            geocoderLocation(marker: marker, coordinate: coordinate)
            marker.map = mapView
            self.manualMarker = marker
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
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) { (places, erro) in
            if let place = places?.first {
                self.titleMarker = place.country
                self.snipetMarker = place.administrativeArea
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
