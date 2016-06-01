//
//  LaunchViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 01/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        if(FBSDKAccessToken.currentAccessToken() != nil) {
            // Users are logged in
            // We set the view similar to launch screen
            
            
        } else {
            //They need to log in
            
        }
    }
    
}
