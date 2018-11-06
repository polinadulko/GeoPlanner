//
//  ListOfPlacesViewController.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/29/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import CoreData

class ListOfPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var placesTableView = UITableView()
    let placeCellIdentifier = "PlaceCell"
    var places: [NSManagedObject]?
    var task: NSManagedObject? {
        didSet {
            let placeFetchRequest = NSFetchRequest<Place>(entityName: "Place")
            let predicate = NSPredicate(format: "task = %@", task!)
            let distanceSortDescriptor = NSSortDescriptor(key: "distanceInMeters", ascending: true)
            placeFetchRequest.predicate = predicate
            placeFetchRequest.sortDescriptors = [distanceSortDescriptor]
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            do {
                places = try managedObjectContext.fetch(placeFetchRequest)
            } catch {
            }
            placesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesTableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        placesTableView.topAnchor.constraint(equalTo: view.topAnchor)
        placesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        placesTableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        placesTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        placesTableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: placeCellIdentifier)
        placesTableView.rowHeight = UITableView.automaticDimension
        placesTableView.estimatedRowHeight = 50
        placesTableView.tableFooterView = UIView(frame: .zero)
        placesTableView.delegate = self
        placesTableView.dataSource = self
        view.addSubview(placesTableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = placesTableView.dequeueReusableCell(withIdentifier: placeCellIdentifier, for: indexPath) as! PlaceTableViewCell
        if places != nil {
            let place = places![indexPath.row]
            cell.nameLabel.text = place.value(forKey: "name") as? String
            cell.addressLabel.text = place.value(forKey: "address") as? String
            if let distance = place.value(forKey: "distanceInMeters") as? Int {
                if distance < 1000 {
                    cell.distanceLabel.text = "\(distance) m"
                } else {
                    let distanceInKm = Double(distance)/1000
                    cell.distanceLabel.text = String(format: "%.1f km", distanceInKm)
                }
            }
            if let photoURLArray = place.value(forKey: "photos") as! [URL]? {
                cell.iconURL = photoURLArray[0]
            } else {
                cell.iconURL = nil
            }
        }
        return cell
    }
    
}
