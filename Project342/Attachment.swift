//
//  Attachment.swift
//  Project342
//
//  Created by Zhe Xian Lee on 16/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData


class Attachment: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

extension Attachment{
    // Used for pass data to Firebase
    func dictionary()-> [String: AnyObject]{
        let dateformater = NSDateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = documentPath[0]
        
        let img = UIImage(named: "\(documentDirectory)/\(filePath!)")!
        let imgData:NSData = UIImagePNGRepresentation(img)!
        return [
            "image": imgData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength) ,
            "sentDate": dateformater.stringFromDate(self.sentDate!)
        ]
    }
}