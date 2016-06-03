//
//  AuthenticationObserver.swift
//  Project342
//
//  Created by Zhe Xian Lee on 04/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation
import Firebase

class AuthenticationObserver {
    
    func observeAuthenticationEvent() {
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            print(user)
        })
    }
    
}

