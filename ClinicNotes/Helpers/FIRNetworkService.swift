//
//  FIRNetworkService.swift
//  ClinicNotes
//
//  Created by Blezin on 26.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import FirebaseDatabase


class FIRNetworkService {
    
    private init() {}
    
    static let shared = FIRNetworkService()
    
    func getSnapshot(ref: DatabaseReference?, completion: @escaping (DataSnapshot) -> ()) {
     
        ref?.observe(.value, with: { (dataSnapshot) in
            if dataSnapshot.exists() {
                completion(dataSnapshot)
            }
        })
        
    }
}











