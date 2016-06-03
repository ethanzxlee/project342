//
//  Attachment.swift
//  Project342
//
//  Created by Zhe Xian Lee on 16/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class Attachment: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Attachment{
    // Used for pass data to Firebase
    func dictionary()-> [String: AnyObject]{
        let dateformater = NSDateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return [
            "image": "\(filePath!)",
            "sentDate": dateformater.stringFromDate(self.sentDate!)
        ]
    }
}