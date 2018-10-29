//
//  TaskTableViewCell.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/29/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewCell: UITableViewCell {
    var nameLabel = UILabel()
    var distanceLabel = UILabel()
    var navigationController: UINavigationController?
    var originalCenter = CGPoint()
    var shouldTaskBeDeleted = false
    var task: NSManagedObject? {
        didSet {
            nameLabel.text = task!.value(forKeyPath: "name") as? String
            let isTaskConnectedToPlace = task!.value(forKey: "isConnectedToPlace") as! Bool
            if isTaskConnectedToPlace {
                let distanceInMeters = task!.value(forKey: "distanceInMeters") as! Int
                if distanceInMeters < 1000 {
                    distanceLabel.text =  "\(distanceInMeters) m"
                } else {
                    let distanceInKm = Double(distanceInMeters)/1000
                    distanceLabel.text = "\(distanceInKm) km"
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        self.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
        
        distanceLabel.numberOfLines = 1
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(distanceLabel)
        distanceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 35.0).isActive = true
        distanceLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3).isActive = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchToInfoAboutPlacesView)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK:- Gesture Actions
    @objc func switchToInfoAboutPlacesView() {
        let placesOnTheMapViewController = PlacesOnTheMapViewController()
        if let controller = navigationController {
            controller.pushViewController(placesOnTheMapViewController, animated: true)
        }
    }
    
}
