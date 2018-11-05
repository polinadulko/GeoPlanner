//
//  PlaceTableViewCell.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/30/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    var nameLabel = UILabel()
    var addressLabel = UILabel()
    var distanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
        
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byWordWrapping
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addressLabel)
        addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        addressLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
        self.bottomAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 10).isActive = true
        
        distanceLabel.numberOfLines = 1
        distanceLabel.textAlignment = .center
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(distanceLabel)
        distanceLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 30).isActive = true
        distanceLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
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

}
