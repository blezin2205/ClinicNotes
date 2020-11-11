//
//  File.swift
//  ClinicNotes
//
//  Created by Blezin on 14.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit


class CustomDeviceCell: UITableViewCell {

    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    func set(currentUser: String?, device: Device) {
        
        deviceLabel.text = device.name
        serialLabel.text = device.serialNumder
        let user = device.createdBy == currentUser ? NSLocalizedString("You", comment: "") : device.createdBy
        createdLabel.text = "\(NSLocalizedString("Created by", comment: "")): \(user); \(device.dateCreated)"
        let _updateUser = device.updatedBy == currentUser ? "You" : device.updatedBy
        guard let updateUser = _updateUser, let updateDate = device.dateUpdated else {return}
        updatedLabel.text = "\(NSLocalizedString("Last update", comment: "")): \(updateUser); \(updateDate)"
        
    }
}
