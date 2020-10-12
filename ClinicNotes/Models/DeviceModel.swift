//
//  DeviceModel.swift
//  ClinicNotes
//
//  Created by Blezin on 12.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import Firebase

struct Device {
    
    let name: String
    let serialNumder: String?
    let ref: DatabaseReference?
    
    
    init(name: String, serialNumber: String?) {
        self.name = name
        self.serialNumder = serialNumber
        self.ref = nil
    }
    
    
    init(snapshot: DataSnapshot) {
        
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    serialNumder = snapshotValue["serialNumder"] as? String
        ref = snapshot.ref
    }
    
     func convertToDictionary() -> Any {
    
           return ["name": name, "serialNumder": serialNumder ]
       }
    
    
}
