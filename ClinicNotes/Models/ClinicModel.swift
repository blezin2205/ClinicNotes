//
//  ClinicModel.swift
//  My Labix
//
//  Created by Alex Stepanov on 21.04.2020.
//  Copyright © 2020 Alex Stepanov. All rights reserved.
//

import UIKit
import Firebase

struct FIRClinic {
    var name: String
    var location: String?
    var city: String?
    var image: String?
    var userId: String
    let ref: DatabaseReference?
    var completed: Bool = false
    
    init(name: String, location: String?, city: String?, image: String?, userId: String) {
        self.name = name
        self.location = location
        self.city = city
        self.image = image
        self.userId = userId
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        location = snapshotValue["location"] as? String
        city = snapshotValue["city"] as? String
        image = snapshotValue["image"] as? String
        userId = snapshotValue["userId"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
 
        return ["name": name, "location": location as Any, "city": city as Any, "image": image as Any, "userId": userId, "completed": completed]
    }
}
