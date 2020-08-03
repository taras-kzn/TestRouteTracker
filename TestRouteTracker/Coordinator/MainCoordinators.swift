//
//  MainCoordinators.swift
//  TestRouteTracker
//
//  Created by admin on 15.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit

final class MainCoordinators: Coordinator {
    //MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    //MARK: init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    //MARK: - Functions
    func start() {
        let vc = LoginViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goRegistrVC() {
        let vc = RegistrViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goMainVC() {
        let vc = MainViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goMapsVC(image: UIImage?) {
        let vc = OneViewController.instantiate()
        vc.imageSelfi = image
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
