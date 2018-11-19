//
//  AppDelegate.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/25/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

let googleMapsAPIKey = "AIzaSyB6OUmlauPDTD8F-VLRm6D7TFl-keHM7hY"
let noPlacesWereFoundDistance = 100000

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var viewController = ViewController()
    var navigationController = UINavigationController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        viewController.managedObjectContext = persistentContainer.viewContext
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController.view.backgroundColor = UIColor.white
        window = UIWindow(frame: UIScreen.main.bounds)
        if let appWindow = window {
            appWindow.rootViewController = navigationController
            appWindow.makeKeyAndVisible()
        }
        GMSServices.provideAPIKey(googleMapsAPIKey)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GeoPlanner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

