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
    let dateUpdated: String?
    let updatedBy: String?
    let dateCreated: String
    let createdBy: String
    let ref: DatabaseReference?
    
    
    init(name: String, serialNumber: String?, dateUpdated: String?, updatedBy: String?, createdBy: String, dateCreated: String) {
        self.name = name
        self.serialNumder = serialNumber
        self.dateUpdated = dateUpdated
        self.createdBy = createdBy
        self.updatedBy = updatedBy
        self.dateCreated = dateCreated
        self.ref = nil
    }
    
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        serialNumder = snapshotValue["serialNumder"] as? String
        dateUpdated = snapshotValue["dateUpdated"] as? String
        updatedBy = snapshotValue["updatedBy"] as? String
        createdBy = snapshotValue["createdBy"] as! String
        dateCreated = snapshotValue["dateCreated"] as! String
        ref = snapshot.ref
    }
    
     func convertToDictionary() -> Any {
    
        return ["name": name, "serialNumder": serialNumder, "dateUpdated": dateUpdated, "updatedBy": updatedBy, "createdBy": createdBy, "dateCreated": dateCreated ]
       }
    
    
}
