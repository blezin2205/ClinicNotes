//
//  CustomTableViewCell.swift
//  My Labix
//
//  Created by Alex Stepanov on 21.04.2020.
//  Copyright © 2020 Alex Stepanov. All rights reserved.
//

import UIKit


class CustomClinicCell: UITableViewCell {
    
    @IBOutlet var imageOfClinic: UIImageView! {
        didSet {
            imageOfClinic.layer.cornerRadius = imageOfClinic.frame.size.height / 10
            imageOfClinic.clipsToBounds = true
        }
    }

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
}