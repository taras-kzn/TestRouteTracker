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
    var marker: GMSMarker?
    
    @IBOutlet var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.settings.myLocationButton = true
        mapView.mapType = .hybrid
        mapView.camera = camera
    }
    
    @IBAction func goHome(_ sender: Any) {
        mapView.animate(toLocation: coordinate)
    }
    
    @IBAction func toggleMarker(_ sender: Any) {
        if marker == nil {
            addMarker()
        } else {
            removeMarker()
        }
    }
    
    func addMarker() {
        let marker = GMSMarker(position: coordinate)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.title = "Привет"
        marker.snippet = "Красная площадь"
        marker.map = mapView
        self.marker = marker
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
}
