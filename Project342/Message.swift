//
//  Message.swift
//  Project342
//
//  Created by Zhe Xian Lee on 16/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class Message: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
}

enum MessageType: Int{
    case NormalMessage
    case Map
    case Image
}

extension Message{
    // Used for pass data(Normal Message or Share Location) to Firebase
    func dictionaryNormalMessageMap() -> [String : AnyObject] {
        
        let dateformater = NSDateFormatter.ISO8601DateFormatter()
        return [
            "content": content!,
            "senderID": senderID!,
            "sentDate": dateformater.stringFromDate(sentDate!),
            "shouldCover": shouldCover!,
            "type": type!
        ]
    }
    
    
    // Used for pass data(Send Image) to Firebase
    func dictionaryImage() -> [String : AnyObject] {
        
        let dateformater = NSDateFormatter.ISO8601DateFormatter()
        let attachment = (attachements?.allObjects as! [Attachment])[0]
        return [
            "content": "",
            "senderID": senderID!,
            "sentDate": dateformater.stringFromDate(sentDate!),
            "shouldCover": shouldCover!,
            "type": type!,
            "attachments": attachment.dictionary()
        ]
    }
}