//
//  UserProfile.swift
//  My Labix
//
//  Created by Alex Stepanov on 10.03.2020.
//  Copyright © 2020 Alex Stepanov. All rights reserved.
//

import Foundation


struct UserProfile {
    
    let id: Int?
    let name: String?
    let email: String?
    
    init(data: [String: Any]) {
        let id = data["id"] as? Int
        let name = data["name"] as? String
        let email = data["email"] as? String
        
        self.id = id
        self.name = name
        self.email = email
        
    }
}
