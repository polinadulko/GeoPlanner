//
//  ViewController.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/25/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Alamofire

class ViewController: UIViewController {
    var addNewTaskBarButton = UIBarButtonItem()
    var tasksTableView = UITableView()
    let taskCellIdentifier = "TaskCell"
    var managedObjectContext: NSManagedObjectContext?
    let locationManager = CLLocationManager()
    var taskFetchedResultsController: NSFetchedResultsController<Task>? = nil
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if taskFetchedResultsController != nil {
            return taskFetchedResultsController!
        }
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let distanceSortDescriptor = NSSortDescriptor(key: "distanceInMeters", ascending: true)
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [dateSortDescriptor, distanceSortDescriptor, nameSortDescriptor]
        taskFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "date", cacheName: nil)
        taskFetchedResultsController!.delegate = self
        do {
            try taskFetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return taskFetchedResultsController!
    }
    var currentLocation: CLLocation?
    var canUpdateLocation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateExpiredTasks()
        
        locationManager.delegate = self
        locationManager.distanceFilter = 300
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        addNewTaskBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(switchToAddNewTaskView))
        navigationItem.rightBarButtonItem = addNewTaskBarButton
        
        tasksTableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tasksTableView.topAnchor.constraint(equalTo: view.topAnchor)
        tasksTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tasksTableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        tasksTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        tasksTableView.register(TaskTableViewCell.self, forCellReuseIdentifier: taskCellIdentifier)
        tasksTableView.rowHeight = UITableView.automaticDimension
        tasksTableView.estimatedRowHeight = 40
        tasksTableView.tableFooterView = UIView(frame: .zero)
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        view.addSubview(tasksTableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateExpiredTasks), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
    }
    
    @objc func updateExpiredTasks() {
        if let context = managedObjectContext {
            do {
                let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
                let currentDate = Calendar.current.startOfDay(for: Date())
                var datePredicate = NSPredicate(format: "date < %@ AND moveToNextDay = %@", argumentArray: [currentDate, false])
                fetchRequest.predicate = datePredicate
                var tasks = try context.fetch(fetchRequest)
                for task in tasks {
                    context.delete(task)
                }
                try context.save()
                datePredicate = NSPredicate(format: "date < %@ AND moveToNextDay = %@", argumentArray: [currentDate, true])
                fetchRequest.predicate = datePredicate
                tasks = try context.fetch(fetchRequest)
                for task in tasks {
                    task.setValue(currentDate, forKey: "date")
                    try task.managedObjectContext!.save()
                }
            }
            catch {
                showAlert(info: "Can't update list of tasks")
            }
        }
    }
    
    //MARK:- Interaction with GoogleMaps
    func createNearbySearchURL(latitude: CLLocationDegrees, longitude: CLLocationDegrees, type: String, keyword: String) -> URL? {
        let urlStr = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + String(latitude) + "," + String(longitude) + "&language=ru&type=" + type + "&keyword=" + keyword + "&rankby=distance&key=\(googleMapsAPIKey)"
        return URL(string: urlStr)
    }
    
    func getNearestPlaces(latitude: CLLocationDegrees, longitude: CLLocationDegrees, task: Task) {
        var type = task.value(forKey: "typeOfPlace") as! String?
        if type == nil {
            type = ""
        }
        var keyword = task.value(forKey: "keywordForPlace") as! String?
        if keyword == nil {
            keyword = ""
        }
        let taskID = task.objectID
        if let url = createNearbySearchURL(latitude: latitude, longitude: longitude, type: type!, keyword: keyword!) {
            guard let networkReachabilityManager = NetworkReachabilityManager() else {
                return
            }
            networkReachabilityManager.startListening()
            if networkReachabilityManager.isReachable {
                request(url).response { (response) in
                    if response.error != nil {
                        DispatchQueue.main.sync {
                            self.showAlert(info: "Can't get info from Google Places")
                        }
                    } else {
                        self.parseData(data: response.data!, userCoordinate: CLLocation(latitude: latitude, longitude: longitude), taskID: taskID)
                    }
                }
            }
        }
    }
    
    func parseData(data: Data, userCoordinate: CLLocation, taskID: NSManagedObjectID) {
        do {
            if let context = managedObjectContext {
                let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                privateMOC.parent = context
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                let places = jsonResponse["results"] as! [AnyObject]
                let task = try privateMOC.existingObject(with: taskID)
                var isTaskDistanceSet = false
                var openPlacesCount = 0
                for place in places {
                    if let geometry = place["geometry"] as! NSDictionary?, let location = geometry["location"] as! NSDictionary? {
                        var isOpenNow = true
                        if let openingHours = place["opening_hours"] as! NSDictionary? {
                            if let openNow = openingHours["open_now"] as! Bool? {
                                isOpenNow = openNow
                            }
                        }
                        if isOpenNow {
                            let placeEntity = NSEntityDescription.entity(forEntityName: "Place", in: privateMOC)
                            if let entity = placeEntity {
                                let newPlace = NSManagedObject(entity: entity, insertInto: privateMOC)
                                let name = place["name"] as! String
                                let address = place["vicinity"] as! String
                                let lat = location["lat"] as! Double
                                let lng = location["lng"] as! Double
                                let placeCoordinate = CLLocation(latitude: lat, longitude: lng)
                                let distance = placeCoordinate.distance(from: userCoordinate)
                                
                                if let photos = place["photos"] as! [NSDictionary]? {
                                    var photoURLArray: [URL] = []
                                    for photo in photos {
                                        let photoReference = photo["photo_reference"] as! String
                                        let photoURLStr = "https://maps.googleapis.com/maps/api/place/photo?photoreference=\(photoReference)&key=\(googleMapsAPIKey)&sensor=false&maxwidth=600&maxheight=600"
                                        if let photoURL = URL(string: photoURLStr) {
                                            photoURLArray.append(photoURL)
                                        }
                                    }
                                    if !photoURLArray.isEmpty {
                                        newPlace.setValue(photoURLArray, forKey: "photos")
                                    }
                                }
                                
                                newPlace.setValue(name, forKey: "name")
                                newPlace.setValue(address, forKey: "address")
                                newPlace.setValue(distance, forKey: "distanceInMeters")
                                newPlace.setValue(lat, forKey: "latitude")
                                newPlace.setValue(lng, forKey: "longitude")
                                
                                newPlace.setValue(task, forKey: "task")
                                if !isTaskDistanceSet {
                                    task.setValue(distance, forKey: "distanceInMeters")
                                    isTaskDistanceSet = true
                                }
                                do {
                                    try privateMOC.save()
                                    managedObjectContext!.performAndWait {
                                        do {
                                            try managedObjectContext!.save()
                                        } catch {
                                            print("Failed to save context: \(error)")
                                        }
                                    }
                                } catch {
                                    print("Failed to save context: \(error)")
                                }
                                openPlacesCount = openPlacesCount + 1
                            }
                        }
                    }
                }
                if openPlacesCount == 0 {
                    task.setValue(noPlacesWereFoundDistance, forKey: "distanceInMeters")
                    do {
                        try privateMOC.save()
                        managedObjectContext!.performAndWait {
                            do {
                                try managedObjectContext!.save()
                            } catch {
                                print("Failed to save context: \(error)")
                            }
                        }
                    } catch {
                        print("Failed to save context: \(error)")
                    }
                }
            }
        } catch {
            DispatchQueue.main.sync {
                showAlert(info: "Can't get info from Google Places")
            }
        }
        canUpdateLocation = true
    }
    
    //MARK:- Bar Buttons actions
    @objc func switchToAddNewTaskView() {
        let addTaskViewController = AddTaskViewController()
        navigationController?.pushViewController(addTaskViewController, animated: true)
    }
}

//MARK:- CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if canUpdateLocation == false {
            return
        } else {
            canUpdateLocation = false
        }
        let currentLocation = locations.last
        let tasksArray = fetchedResultsController.fetchedObjects
        if let location = currentLocation, let tasks = tasksArray, let context = managedObjectContext {
            self.currentLocation = location
            do {
                let placeFetchRequest = NSFetchRequest<Place>(entityName: "Place")
                let places = try context.fetch(placeFetchRequest)
                for place in places {
                    context.delete(place)
                }
                try context.save()
            } catch {
            }
            for task in tasks {
                let isConnectedToPlace = task.value(forKey: "isConnectedToPlace") as! Bool
                if isConnectedToPlace {
                    getNearestPlaces(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, task: task)
                }
            }
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tasksTableView.reloadData()
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.fetchedResultsController.sections != nil {
            let firstObjectInSection:NSManagedObject = self.fetchedResultsController.sections![section].objects![0] as! NSManagedObject
            let dateForSection = firstObjectInSection.value(forKey: "date") as! Date
            let currentDate = Date()
            let compareDates = Calendar.current.compare(dateForSection, to: currentDate, toGranularity: .month)
            if compareDates == .orderedSame {
                let startOfDayCurrentDate = Calendar.current.startOfDay(for: currentDate)
                let startOfDayDateForSection = Calendar.current.startOfDay(for: dateForSection)
                let differenceInDays = Calendar.current.dateComponents([.day], from: startOfDayCurrentDate, to: startOfDayDateForSection).day!
                if differenceInDays == 0 {
                    return "Today"
                } else if differenceInDays == 1 {
                    return "Tomorrow"
                } else if differenceInDays > 1 && differenceInDays < 6 {
                    let weekday = Calendar.current.component(.weekday, from: dateForSection)
                    let listOfWeekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                    return listOfWeekdays[weekday-1]
                }
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: dateForSection)
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTableView.dequeueReusableCell(withIdentifier: taskCellIdentifier, for: indexPath) as! TaskTableViewCell
        let task = fetchedResultsController.object(at: indexPath)
        let isConnectedToPlace = task.value(forKey: "isConnectedToPlace") as! Bool
        let distance = task.value(forKey: "distanceInMeters") as! Int?
        if isConnectedToPlace && (distance == nil) && (currentLocation != nil) {
            getNearestPlaces(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude, task: task)
        }
        cell.task = task
        cell.navigationController = navigationController
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let markAsCompletedAction = UITableViewRowAction(style: .destructive, title: "Completed", handler: { (row, indexPath) in
            let task = self.fetchedResultsController.object(at: indexPath)
            if let context = self.managedObjectContext {
                context.delete(task)
                do {
                    try context.save()
                } catch {
                    self.showAlert(info: "Can't delete task")
                }
            }
        })
        markAsCompletedAction.backgroundColor = UIColor.init(red: 252/255, green: 33/255, blue: 37/255, alpha: 1.0)
        return [markAsCompletedAction]
    }
}
