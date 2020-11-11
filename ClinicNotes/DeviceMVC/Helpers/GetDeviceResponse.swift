//
//  GetDeviceResponse.swift
//  ClinicNotes
//
//  Created by Blezin on 11.11.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation

import FirebaseDatabase


struct GetDeviceResponse {

    let devices: Array<Device>
    
    init(snapshot: DataSnapshot) {
        
        var _devices = Array<Device>()
        for item in snapshot.children {
            let clinic = Device(snapshot: item as! DataSnapshot)
            _devices.append(clinic)
            
        }
        self.devices = _devices
        
    }
}
