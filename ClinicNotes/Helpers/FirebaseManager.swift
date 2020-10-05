//
//  FirebaseManager.swift
//  ClinicNotes
//
//  Created by Blezin on 03.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import UIKit
import Firebase


class FirebaseManager {

    static func fetchingUserData(complition: @escaping (_ courses: CurrentUser)->() ) {
        
        if Auth.auth().currentUser != nil {
       
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                Database.database().reference()
                    .child("users")
                    .child(uid)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let userData = snapshot.value as? [String: Any] else { return }
                        let currentUser = CurrentUser(uid: uid, data: userData)
                        complition(currentUser!)
                       
                        
                    }) { (error) in
                        print(error)
            }
        }
    }
    
}
