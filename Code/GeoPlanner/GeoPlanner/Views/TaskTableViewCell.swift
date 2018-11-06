//
//  TaskTableViewCell.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/29/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class TaskTableViewCell: UITableViewCell {
    var nameLabel = UILabel()
    var distanceLabel = UILabel()
    var navigationController: UINavigationController?
    var originalCenter = CGPoint()
    var shouldTaskBeDeleted = false
    var task: NSManagedObject? {
        didSet {
            nameLabel.text = task!.value(forKeyPath: "name") as? String
            if let distanceInMeters = task!.value(forKey: "distanceInMeters") as! Int? {
                if distanceInMeters == noPlacesWereFoundDistance {
                    distanceLabel.text = "-"
                }
                else if distanceInMeters < 1000 {
                    distanceLabel.text =  "\(distanceInMeters) m"
                } else {
                    let distanceInKm = Double(distanceInMeters)/1000
                    distanceLabel.text = String(format: "%.1f km", distanceInKm)
                }
            } else {
                distanceLabel.text = ""
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
        distanceLabel.textAlignment = .center
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(distanceLabel)
        distanceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 30).isActive = true
        distanceLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        
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
        if let selectedTask = task {
            if let distance = selectedTask.value(forKey: "distanceInMeters") as! Int? {
                guard let networkReachabilityManager = NetworkReachabilityManager() else {
                    return
                }
                networkReachabilityManager.startListening()
                if distance != noPlacesWereFoundDistance && networkReachabilityManager.isReachable {
                    let infoAboutPlacesTabBarController = InfoAboutPlacesTabBarController()
                    if let controller = navigationController {
                        infoAboutPlacesTabBarController.task = task
                        controller.pushViewController(infoAboutPlacesTabBarController, animated: true)
                    }
                }
            }
        }
    }
    
}
