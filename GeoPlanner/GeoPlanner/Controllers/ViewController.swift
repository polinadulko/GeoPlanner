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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    var addNewTaskBarButton = UIBarButtonItem()
    var tasksTableView = UITableView()
    let taskCellIdentifier = "taskCell"
    var managedObjectContext: NSManagedObjectContext?
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
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteExpiredTasks()
        
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
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        view.addSubview(tasksTableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteExpiredTasks), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
    }
    
    @objc func deleteExpiredTasks() {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        let currentDate = Calendar.current.startOfDay(for: Date())
        let datePredicate = NSPredicate(format: "date < %@ AND moveToNextDay = %@", argumentArray: [currentDate, false])
        fetchRequest.predicate = datePredicate
        if let context = managedObjectContext {
            do {
                let tasks = try context.fetch(fetchRequest)
                for task in tasks {
                    context.delete(task)
                }
                try context.save()
            }
            catch {
                showAlert(info: "Can't update list of tasks")
            }
        }
    }
    
    //MARK:- Location Manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated location")
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        if let context = managedObjectContext {
            do {
                let tasks = try context.fetch(fetchRequest)
                for task in tasks {
                    let connectedToPlace = task.value(forKey: "isConnectedToPlace") as! Bool
                    if connectedToPlace {
                        let distance = 2000
                        task.setValue(distance, forKey: "distanceInMeters")
                    }
                }
                try context.save()
            } catch {
                showAlert(info: "Can't update info connected with location")
            }
        }
    }
    
    //MARK:- Bar Buttons actions
    @objc func switchToAddNewTaskView() {
        let addTaskViewController = AddTaskViewController()
        navigationController?.pushViewController(addTaskViewController, animated: true)
    }
    
    //MARK:- TableView protocols
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
                    let listOfWeekdays = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
                    return listOfWeekdays[weekday]
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
        cell.task = fetchedResultsController.object(at: indexPath)
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
    
    //MARK: - FetchedResultsController delegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tasksTableView.reloadData()
    }
}

