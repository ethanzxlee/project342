//
//  LaunchViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 01/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import FirebaseAuth

class LaunchViewController: UIViewController {

    @IBOutlet weak var launchImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        //try! FIRAuth.auth()!.signOut()
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = FIRAuth.auth()?.currentUser {
                // User is logged in.
            } else {
                // No user is logged in.
                self.launchImage.hidden = true
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let user = FIRAuth.auth()?.currentUser {
            self.performSegueWithIdentifier("ShowTabBarViewController1", sender: nil)
        }
    }
}
