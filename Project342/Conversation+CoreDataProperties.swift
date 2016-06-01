//
//  Conversation+CoreDataProperties.swift
//  Project342
//
//  Created by Fagan Ooi on 01/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Conversation {

    @NSManaged var conversationID: String?
    @NSManaged var conversationName: String?
    @NSManaged var coverCode: String?
    @NSManaged var isLocked: NSNumber?
    @NSManaged var lastMessageTimestamp: String?
    @NSManaged var startIndex: NSNumber?
    @NSManaged var conversationPhotoPath: String?
    @NSManaged var type: NSNumber?
    @NSManaged var members: NSSet?
    @NSManaged var messages: NSSet?

}
