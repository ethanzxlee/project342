//
//  Conversation.swift
//  Project342
//
//  Created by Zhe Xian Lee on 16/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation
import CoreData
import Firebase

final class Conversation: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    

}

enum ConversationType: Int {
    case Personal
    case Group
}

extension Conversation{
    
    // Used for pass data to Firebase
    func dictionary()-> [String: AnyObject] {
        // FIXME: NSUSERDEFAULT
        let membersTempList = members?.allObjects as! [Contact]
        var membersList = [String: String]()
        for eachMember in membersTempList{
            membersList[eachMember.userId!] = eachMember.userId!
        }
        let currentUser = FIRAuth.auth()?.currentUser
        membersList[currentUser!.uid] = currentUser!.uid
        
        return [
            "coverCode": coverCode!,
            "lastMessageTimestamp":lastMessageTimestamp!,
            "type": type!,
            "conversationName": conversationName!,
            "membersID": membersList,
            "conversationPhotoPath": conversationPhotoPath!
        ]
        
    }

}