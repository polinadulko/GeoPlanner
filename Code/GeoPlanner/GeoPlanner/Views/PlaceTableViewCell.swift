//
//  PlaceTableViewCell.swift
//  GeoPlanner
//
//  Created by Polina Dulko on 10/30/18.
//  Copyright © 2018 Polina Dulko. All rights reserved.
//

import UIKit
import Alamofire

class PlaceTableViewCell: UITableViewCell {
    var nameLabel = UILabel()
    var addressLabel = UILabel()
    var distanceLabel = UILabel()
    var iconImageView = UIImageView()
    var iconURL: URL? {
        didSet {
            Alamofire.request(iconURL!).responseData { (response) in
                if response.error == nil {
                    self.iconImageView.image = UIImage(data: response.data!)
                }
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        iconImageView = UIImageView(image: UIImage(named: "question"))
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.clipsToBounds = true
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(iconImageView)
        iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        iconImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: iconImageView.leftAnchor, constant: -20).isActive = true
        
        addressLabel.numberOfLines = 0
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addressLabel)
        addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        addressLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        
        distanceLabel.numberOfLines = 1
        distanceLabel.textAlignment = .left
        distanceLabel.textColor = UIColor(displayP3Red: 0, green: 51/255, blue: 25/255, alpha: 1)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(distanceLabel)
        distanceLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 20).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        distanceLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 15).isActive = true
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
