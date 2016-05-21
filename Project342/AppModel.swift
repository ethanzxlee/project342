//
//  AppModel.swift
//  Project342
//
//  Created by Fagan Ooi on 18/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData

class AppModel:NSManagedObjectModel{
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    // MARK: -Conversation
    // Get the max range of conversation in Core Data
    func getConversationMaxRange()->Int{
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        do{
            if let getConversationList = try managedContext.executeFetchRequest(getConversationRequest) as? [Conversation]{
                return getConversationList.count
            }
        }catch{}
        return 0
    }
    
    /**
     Get a list of conversation for display in 'Recently Contact' tab with limit
     */
    func getConversationList(limit: Int)->[Conversation]{
        
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        do{
            getConversationRequest.fetchLimit = limit
            if let getConversationList = try managedContext.executeFetchRequest(getConversationRequest) as? [Conversation]{
                if getConversationList.count > 1 {
                    let sortResult = getConversationList.sort(sortBasedOnLastMessage)
                    return sortResult
                }
                
            }
        }catch{}
        return []
    }
    
    func getAllConversationList()->[Conversation]{
        
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        do{
            if let getConversationList = try managedContext.executeFetchRequest(getConversationRequest) as? [Conversation]{
                if getConversationList.count > 1 {
                    let sortResult = getConversationList.sort(sortBasedOnLastMessage)
                    return sortResult
                }
            }
        }catch{}
        return []
    }
    
    
    /**
     Create new conversation
     Return true: success
     Return false: fail
     */
    func createNewConversation(members:[Contact])->Bool{
        if let conversation = NSEntityDescription.insertNewObjectForEntityForName("Conversation", inManagedObjectContext: managedContext)as? Conversation{
            
            /**
             Update the conservation list of each user before add them into a new conversation
             */
            for eachMember in members{
                var memberConversationList = eachMember.conversations?.allObjects as! [Conversation]
                memberConversationList.append(conversation)
                eachMember.conversations = NSSet(array: memberConversationList)
            }
            /**
             Add the members into conversation list
             */
            conversation.members = NSSet(array: members)
            conversation.conversationName = self.getConversationName(members)
            
            do{
                try managedContext.save()
            }catch{
                return false
            }
            
        }
        return true
    }
    
    // Get name of conversation
    func getConversationName(members: [Contact])->String{
        var name: String = ""
        for eachMember in members{
            let firstName = eachMember.firstName!
            name = "\(name), \(firstName)"
        }
        
        // Remove the ',' and ' ' in the string
        name.removeAtIndex(name.startIndex)
        name.removeAtIndex(name.startIndex)
        
        return name
    }
    
    // Delete particular conversation
    func deleteConversation(conversation: Conversation){
        do{
            managedContext.deleteObject(conversation)
            try managedContext.save()
        }catch{}
        
    }
    
    // Delete all conversations
    func deleteAllConversations(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                do{
                    let conversationList = self.getAllConversationList()
                    for conversation in conversationList{
                        self.managedContext.deleteObject(conversation)
                    }
                    try self.managedContext.save()
                }catch{}
            }
        }
    }
    
    // Do predicate search
    func searchResult(str: String)->[Conversation]{
        // Change the target and searchTerm to lowercaseString to enable get insensitice result
        // Any used for NSArray or NSSet
        let predicate = NSPredicate(format:
            "(conversationName.lowercaseString CONTAINS %@) OR " +      // Get the string contain @ in conversationName
                "(ANY members.firstName.lowercaseString CONTAINS %@) OR " + // Get the string contain @ in firstName
                "(ANY members.lastName.lowercaseString CONTAINS %@) OR " +  // Get the string contain @ in lastName
                "(ANY members.firstName.lowercaseString IN %@) OR " +       // Get the string that members.firstName contain inside the @
                "(ANY messages.content.lowercaseString CONTAINS %@) OR " +
            "(ANY messages.content.lowercaseString IN %@)",
                                    str.lowercaseString, str.lowercaseString, str.lowercaseString, str.lowercaseString, str.lowercaseString, str.lowercaseString)
        
        var resultArray = [Conversation]()
        do{
            // Get the conversation list from Core Data and filter it using the name
            let fetchRequest = NSFetchRequest(entityName: "Conversation")
            // Sorted by conversationName, members.lastName, members.firstName
            let conversationList = try managedContext.executeFetchRequest(fetchRequest) as NSArray
            resultArray = conversationList.filteredArrayUsingPredicate(predicate) as! [Conversation]
            return resultArray
        }catch{}
        return []
    }
    
    
    // MARK: -Contact
    /**
     Get a list of contact
     */
    func getContactList()->[Contact]{
        
        let getContactRequest = NSFetchRequest(entityName: "Contact")
        let firstNameSort = NSSortDescriptor(key: "firstName", ascending: true)
        getContactRequest.sortDescriptors = [firstNameSort]
        do{
            if let getContactList = try managedContext.executeFetchRequest(getContactRequest) as? [Contact]{
                return getContactList
            }
        }catch{}
        return []
    }
    
    func searchContactList(str: String)-> [Contact]{
        let predicate = NSPredicate(format:
            "(firstName.lowercaseString CONTAINS %@) OR " +
                "(lastName.lowercaseString CONTAINS %@) OR" +
            "(firstName.lowercaseString IN %@)",
                                    str.lowercaseString, str.lowercaseString, str.lowercaseString)
        
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        let firstNameSort = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [firstNameSort]
        var resultArray = [Contact]()
        do{
            let contactList = try managedContext.executeFetchRequest(fetchRequest) as NSArray
            resultArray = contactList.filteredArrayUsingPredicate(predicate) as! [Contact]
            return resultArray
        }catch{}
        return []
    }
    
    
    // MARK: - Comparison
    func sortBasedOnLastMessage(conversation1: Conversation, conversation2: Conversation)-> Bool{
        let msg1 = ((conversation1.messages?.allObjects) as! [Message])
        let msg2 = ((conversation2.messages?.allObjects) as! [Message])
        if msg1.count > 0 && msg2.count > 0{
            let date1 = msg1[msg1.endIndex-1].sentDate
            let date2 = msg2[msg2.endIndex-1].sentDate
            
            return date1?.compare(date2!) == NSComparisonResult.OrderedDescending
        }
        
        // Mean first conversation gt message
        // Meanwhile 2nd conversation dont hv message
        // Thus, first display first
        if msg1.count > 0 && msg2.count == 0{
            return true
        }
        return false
    }
    
    
    
}