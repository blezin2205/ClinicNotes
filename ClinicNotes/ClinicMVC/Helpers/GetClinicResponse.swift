//
//  GetClinicResponse.swift
//  ClinicNotes
//
//  Created by Blezin on 26.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct GetClinicResponse {

    let clinics: Array<Clinic>
    
    init(snapshot: DataSnapshot) {
        
        var _clinics = Array<Clinic>()
        for item in snapshot.children {
            let clinic = Clinic(snapshot: item as! DataSnapshot)
            _clinics.append(clinic)
            
        }
        self.clinics = _clinics
        
    }
}

