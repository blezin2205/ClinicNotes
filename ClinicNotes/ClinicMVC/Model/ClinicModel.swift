//
//  ClinicModel.swift
//  ClinicNotes
//
//  Created by Alex Stepanov on 21.04.2020.
//  Copyright © 2020 Alex Stepanov. All rights reserved.
//

import UIKit
import Firebase




struct Clinic {
  
    
    var name: String
    var location: String?
    var city: String?
    var image: String?
    var userId: String
    let ref: DatabaseReference?
    var longitude: String?
    var latitude: String?
    
    init(name: String, location: String?, city: String?, image: String?, userId: String, longitude: String?, latitude: String?) {
        
        self.name = name
        self.location = location
        self.city = city
        self.image = image
        self.userId = userId
        self.ref = nil
        self.longitude = longitude
        self.latitude = latitude
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        location = snapshotValue["location"] as? String
        city = snapshotValue["city"] as? String
        image = snapshotValue["image"] as? String
        userId = snapshotValue["userId"] as! String
        longitude = snapshotValue["longitude"] as? String
        latitude = snapshotValue["latitude"] as? String
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        return ["name": name, "location": location as Any, "city": city as Any, "image": image as Any, "userId": userId, "longitude": longitude as Any, "latitude": latitude as Any]
    }
}

