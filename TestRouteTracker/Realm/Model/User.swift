//
//  User.swift
//  TestRouteTracker
//
//  Created by admin on 14.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    override static func primaryKey() -> String? {
        return "login"
    }
}
