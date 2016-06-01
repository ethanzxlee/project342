//
//  TabBarController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 24/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAuth

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor.themeColor()
        
        // Using this listener, we
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                print("I'm logged in")
                
                for profile in user.providerData {
                    let providerID = profile.providerID
                    let uid = profile.uid;  // Provider-specific UID
                    let name = profile.displayName
                    let email = profile.email
                    let photoURL = profile.photoURL
                    
                    print(providerID)
                    print(uid)
                    print(name)
                    print(email)
                    print(photoURL)
                }
                
            } else {
                // No user is signed in.
            }
        }
    }

}
