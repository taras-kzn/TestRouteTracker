//
//  Coordinator.swift
//  TestRouteTracker
//
//  Created by admin on 15.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
