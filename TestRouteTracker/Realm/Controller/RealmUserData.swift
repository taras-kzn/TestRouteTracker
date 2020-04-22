//
//  RealmUserData.swift
//  TestRouteTracker
//
//  Created by admin on 14.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import RealmSwift


class RealmUserData {
    
    func saveUserData(login: String, password: String) {
        var saveUser = [User]()
        let user = User()
        user.login = login
        user.password = password
        saveUser.append(user)
        do {
            let realm = try Realm()
            print(realm.configuration.fileURL)
            realm.beginWrite()
            realm.add(saveUser, update:.all)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
}
