//
//  RootController.swift
//  TestRouteTracker
//
//  Created by admin on 23.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit

class RootController: UIStoryboardSegue {
    
    override func perform() {
        UIApplication.shared.keyWindow?.rootViewController = destination
    }
}
