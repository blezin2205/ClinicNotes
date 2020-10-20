//
//  RecentsModel.swift
//  ClinicNotes
//
//  Created by Blezin on 20.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct Recents {
  
    let comment: String?
    let device: String?
    let clinic: String?
    let user: String?
    let date: String?
    let ref: DatabaseReference?
    
}




