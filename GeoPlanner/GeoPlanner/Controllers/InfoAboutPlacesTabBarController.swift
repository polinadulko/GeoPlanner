//
//  InfoAboutPlacesTabBarController.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/29/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import CoreData

class InfoAboutPlacesTabBarController: UITabBarController {
    let listOfPlacesViewController = ListOfPlacesViewController()
    let placesOnTheMapViewController = PlacesOnTheMapViewController()
    var listOfPlacesTabBarItem = UITabBarItem()
    var placesOnTheMapTabBarItem = UITabBarItem()
    var backBarButton = UIBarButtonItem()
    var task: NSManagedObject? {
        didSet {
            listOfPlacesViewController.task = task
            placesOnTheMapViewController.task = task
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(switchToMainView))
        navigationItem.leftBarButtonItem = backBarButton
        listOfPlacesTabBarItem = UITabBarItem(title: "List", image: UIImage(named: "ListTabBarImage"), tag: 0)
        listOfPlacesViewController.tabBarItem = listOfPlacesTabBarItem
        placesOnTheMapTabBarItem = UITabBarItem(title: "Map", image: UIImage(named: "MapTabBarImage"), tag: 1)
        placesOnTheMapViewController.tabBarItem = placesOnTheMapTabBarItem
        viewControllers = [listOfPlacesViewController, placesOnTheMapViewController]
    }
    
    @objc func switchToMainView() {
        navigationController?.popViewController(animated: true)
    }
    
}
