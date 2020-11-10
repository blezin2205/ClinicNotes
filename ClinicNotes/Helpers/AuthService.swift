//
//  AuthService.swift
//  ClinicNotes
//
//  Created by Blezin on 21.10.2020.
//  Copyright © 2020 Blezin'sDev. All rights reserved.
//

import FirebaseAuth


protocol AuthServiceDelegate {
    func authServiceSignIn()
}

class AuthService {

    func isUserLoggedIn() -> Bool {
      return Auth.auth().currentUser != nil
    }

var delegate: AuthServiceDelegate?

    
    func checkLoggedIn() {
        
        if isUserLoggedIn() {
            delegate?.authServiceSignIn()
        }
    }
}
