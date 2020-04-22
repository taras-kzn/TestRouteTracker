//
//  MainViewController.swift
//  TestRouteTracker
//
//  Created by admin on 15.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, Storyboarded {
    
    var coordinator: MainCoordinators?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func actionMapsButton(_ sender: Any) {
        coordinator?.goMapsVC()
    }
    
    @IBAction func backLoginButton(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLogin")
        coordinator?.start()
    }
}
