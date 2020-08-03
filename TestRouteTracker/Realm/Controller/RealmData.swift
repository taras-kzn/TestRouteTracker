//
//  RealmData.swift
//  TestRouteTracker
//
//  Created by admin on 08.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import RealmSwift
import GoogleMaps

final class RealmData {
    //MARK: - Functions
    func saveRouteData(_ route: String) {
        let saveRoute = SaveRoute()
        saveRoute.encodedPath = route
        do {
            let realm = try Realm()
            print(realm.configuration.fileURL)
            let oldRoute = realm.objects(SaveRoute.self)
            realm.beginWrite()
            realm.delete(oldRoute)
            realm.add(saveRoute)
            try realm.commitWrite()
        } catch {
            print(error)
        }
        
    }
    
    func loadRouteData(route: GMSPolyline) {
        do {
            let realm = try Realm()
            let path = realm.objects(SaveRoute.self)
            var stringPath = String()
            for i in path {
                stringPath = i.encodedPath
            }
            route.path = GMSPath(fromEncodedPath: stringPath )
        } catch {
            print(error)
        }
        
    }
}
