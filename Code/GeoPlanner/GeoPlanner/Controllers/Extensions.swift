//
//  Extensions.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/29/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(info:String) {
        let alert = UIAlertController(title: nil, message: info, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
