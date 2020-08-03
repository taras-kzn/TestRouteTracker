//
//  Storyboarded.swift
//  TestRouteTracker
//
//  Created by admin on 15.04.2020.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit
//MARK: - protocol
protocol Storyboarded {
    //MARK: Function
    static func instantiate() -> Self
}
//MARK: - extension Storyboarded
extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let id = String(describing: self)
        let storyboarde = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboarde.instantiateViewController(withIdentifier: id) as! Self
    }
}
