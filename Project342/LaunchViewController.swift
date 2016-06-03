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
//        try! FIRAuth.auth()!.signOut()
        
        // Show the same launch image if users is logged in
        // Else for new user, hide launch image and show
        // the actual view to log in and sign up
        if FIRAuth.auth()?.currentUser != nil {
            // User is logged in.
        } else {
            // No user is logged in.
            self.launchImage.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Perform segue to tab controller for logged in user
        if FIRAuth.auth()?.currentUser != nil {
            self.performSegueWithIdentifier("ShowTabBarViewController1", sender: nil)
        }
    }
    
    @IBAction func unwindToLaunch(segue: UIStoryboardSegue) {
        
    }
}
