//
//  Launch.swift
//  TestRouteTracker
//
//  Created by admin on 23.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit

class Launch: UIViewController, Storyboarded {
    
    var coordinator: MainCoordinators?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isLogin") {
            coordinator?.goMainVC()
        } else {
            coordinator?.goLoginVC()
        }
    }
}
