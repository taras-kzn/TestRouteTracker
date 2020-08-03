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

final class OneViewController: UIViewController, Storyboarded {
    //MARK: - IBOutlet
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var mapView: GMSMapView!
    //MARK: - Properties
    private let realmService = RealmData()
    private var marker: GMSMarker?
    private let locationManager = LocationManager.instance
    private var geocoder: CLGeocoder = CLGeocoder()
    private var status = false
    private var saveRoute: GMSPolyline?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    weak var coordinator: MainCoordinators?
    var imageSelfi: UIImage?
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
        actionButton.layer.cornerRadius = 15
    }
    //MARK: - Actions
    @IBAction func action(_ sender: UIButton) {
        if status {
            actionButton.setTitle("Start", for: .normal)
            locationManager.stopUpdatingLocation()
            locationManager.stopMonitoringSignificantLocationChanges()
            guard let stringPath = routePath?.encodedPath() else {return}
            realmService.saveRouteData(stringPath)
            route?.map = nil
            routePath?.removeAllCoordinates()
            mapView.clear()
            status = false
        } else {
            actionButton.setTitle("Stop", for: .normal)
            saveRoute?.map = nil
            route?.map = nil
            route = GMSPolyline()
            route?.strokeWidth = 5
            routePath = GMSMutablePath()
            route?.map = mapView
            locationManager.startUpdatingLocation()
            status = true
        }
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
    //MARK: - Private Functions
    private func configureMap() {
        mapView.mapType = .hybrid
        mapView.addSubview(actionButton)
        mapView.delegate = self
    }
    
    private func configureLocationManager() {
        locationManager.location.asObservable().bind { [weak self] location in
            guard let location = location else {return}
            self?.newAddMarker(coordinate: location.coordinate)
            self?.routePath?.add(location.coordinate)
            self?.route?.path = self?.routePath
            let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
            self?.mapView.animate(to: position)
        }
    }
    
    private func newAddMarker(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let view = UIView(frame: rect)
        let imageView = UIImageView(frame: rect)
        imageView.image = self.imageSelfi
        view.layer.cornerRadius = 30
        view.layer.shadowOpacity = 0.9
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        view.addSubview(imageView)
        marker.iconView = view
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        marker.map = mapView
        mapView.animate(to: camera)
    }
    
    private func actionAlert(action: UIAlertAction! = nil) {
        actionButton.setTitle("Start", for: .normal)
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        guard let stringPath = routePath?.encodedPath() else {return}
        realmService.saveRouteData(stringPath)
        route?.map = nil
        routePath?.removeAllCoordinates()
        status = false
        oldRoute()
    }
    
    private func oldRoute() {
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
    
    private func addMarker(position: CLLocationCoordinate2D, title: String, snipet: String) {
        let marker = GMSMarker(position: position)
        let camera = GMSCameraPosition.camera(withTarget: position, zoom: 17)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.title = title
        marker.snippet = snipet
        marker.map = mapView
        mapView.animate(to: camera)
        self.marker = marker
    }
    
    private func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    private func geocoderLocation(marker: GMSMarker, coordinate: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (places, error) in
            if let place = places?.first {
                marker.snippet = place.administrativeArea
                marker.title = place.country
            }
        }
    }
}
//MARK: - GMSMapViewDelegate
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

