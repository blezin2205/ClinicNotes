//
//  NoteModel.swift
//  ClinicNotes
//
//  Created by Blezin on 14.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import Firebase

struct Note {
    
    
    let comment: String
    let type: String
    let user: String
    let dateUpdated: String
    let ref: DatabaseReference?
    
    init(comment: String, type: String, dateUpdated: String, user: String) {
        self.comment = comment
        self.type = type
        self.user = user
        self.dateUpdated = dateUpdated
        self.ref = nil
        
    }
    
    init(snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        comment = snapshotValue["comment"] as! String
        type = snapshotValue["type"] as! String
        dateUpdated = snapshotValue["dateUpdated"] as! String
        ref = snapshot.ref
        user = snapshotValue["user"] as! String
    }
    
    func convertToDictionary() -> Any {
        
        return ["comment": comment, "type": type, "dateUpdated": dateUpdated, "user": user ]
    }
    
    
    
    
}
