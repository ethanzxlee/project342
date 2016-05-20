//
//  Contact+CoreDataProperties.swift
//  Project342
//
//  Created by Zhe Xian Lee on 20/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Contact {

    @NSManaged var firstName: String?
    @NSManaged var imagePath: String?
    @NSManaged var lastName: String?
    @NSManaged var sectionTitleFirstName: String?
    @NSManaged var sectionTitleLastName: String?
    @NSManaged var userId: String?
    @NSManaged var conversations: NSSet?

}
