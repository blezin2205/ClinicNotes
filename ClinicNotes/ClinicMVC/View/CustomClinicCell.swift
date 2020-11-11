//
//  CustomTableViewCell.swift
//  My Labix
//
//  Created by Alex Stepanov on 21.04.2020.
//  Copyright © 2020 Alex Stepanov. All rights reserved.
//

import UIKit
import SDWebImage



class CustomClinicCell: UITableViewCell {
    
    static let reuseId = "CustomClinicCell"
    
    @IBOutlet var imageOfClinic: UIImageView! {
        didSet {
            imageOfClinic.layer.cornerRadius = imageOfClinic.frame.size.height / 10
            imageOfClinic.clipsToBounds = true
        }
    }

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    
    func set(clinic: Clinic) {
        
        if let clinicImage = clinic.image {
                  let url = URL(string: clinicImage)
                  imageOfClinic.sd_imageIndicator = SDWebImageActivityIndicator.gray
                  imageOfClinic.sd_setImage(with: url, completed: nil)
               
              } else {
                  imageOfClinic.image = UIImage(named: "placeholder-image")
              }
        nameLabel.text = clinic.name
        locationLabel.text = clinic.location
        cityLabel.text = clinic.city
        self.accessoryType = .detailButton
        
    }
}
