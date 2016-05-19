//
//  FirstViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class RecentChatViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let c = CipherModel()
        c.syncContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

