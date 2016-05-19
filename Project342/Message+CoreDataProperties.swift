//
//  Message+CoreDataProperties.swift
//  Project342
//
//  Created by Fagan Ooi on 19/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var content: String?
    @NSManaged var sentDate: NSDate?
    @NSManaged var shouldCover: NSNumber?
    @NSManaged var attachements: NSSet?
    @NSManaged var conversation: Conversation?

}
