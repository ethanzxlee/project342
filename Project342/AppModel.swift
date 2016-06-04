////
//  AppModel.swift
//  Project342
//
//  Created by Fagan Ooi on 18/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import CoreData
import Firebase

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
     
     Parameter: The number of conversation would like to get
     
     Result: Array of Dictionary consist of conversationID, conversationName, conversationPhotoPath, type
     */
    func getConversationList(limit: Int)->[[String: AnyObject]]{
        
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        do{
            getConversationRequest.fetchLimit = limit
            getConversationRequest.propertiesToFetch = ["conversationID","conversationName", "conversationPhotoPath", "type"]
            getConversationRequest.resultType = .DictionaryResultType
            let sortDescriptor = NSSortDescriptor(key: "lastMessageTimestamp", ascending: false)
            getConversationRequest.sortDescriptors = [sortDescriptor]
            if let getConversationList = try managedContext.executeFetchRequest(getConversationRequest) as? [[String: AnyObject]]{
                return getConversationList
            }

                
            
        }catch{}
        return []
    }
    
    /**
     Get the conversation based on conversation ID
     
     Parameter: conversation ID
     */
    func getConversation(conversationID: String)->Conversation{
        
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        getConversationRequest.predicate = NSPredicate(format: "conversationID = %@", conversationID)
        var result : Conversation?
        do{
            
            if let getConversation = try managedContext.executeFetchRequest(getConversationRequest).first as? Conversation{
                result = getConversation
            }
            
        }catch{
            print(error)
        }
        return result!
    }
    
    
    /**
     Get all list of Conversation stored in Core Data
     
     ** Used for Delete All Conversation
     */
    func getAllConversationList()->[Conversation]{
        
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        do{
            
            if let getConversationList = try managedContext.executeFetchRequest(getConversationRequest) as? [Conversation]{
                return getConversationList
            }

        }catch{}
        return []
    }
    
    
    /**
     Create new conversation
     
     Paramter: An array of members
     
     Return: Conversation type of data
     */
    func createNewConversation(members:[Contact])->Conversation{
        
        if members.count == 1 {
            let getConversationRequest = NSFetchRequest(entityName: "Conversation")
            
            do{
                if let getConversationList = try managedContext.executeFetchRequest(getConversationRequest) as? [Conversation]{
                    for conversation in getConversationList {
                        if conversation.members?.count == 1 {
                            
                            let membersTempList = conversation.members?.allObjects as! [Contact]
                            if membersTempList[0].userId! == members[0].userId! {
                                return conversation
                            }
                        }
                    }
                }
                
            }catch{}

        }
        
        if let conversation = NSEntityDescription.insertNewObjectForEntityForName("Conversation", inManagedObjectContext: managedContext)as? Conversation{
            /**
             Update the conservation list of each user before add them into a new conversation
             */
            for eachMember in members{
                var memberConversationList = eachMember.conversations?.allObjects as! [Conversation]
                memberConversationList.append(conversation)
                eachMember.conversations = NSSet(array: memberConversationList)
            }
            
            if members.count > 1 {
                // Set group photo
                conversation.conversationPhotoPath = "group.png"
                conversation.type = ConversationType.Group.rawValue
            }else{
                conversation.conversationPhotoPath = members[0].userId
                conversation.type = ConversationType.Personal.rawValue
            }
            
            /**
             Add the members into conversation list
             */
            conversation.members = NSSet(array: members)
            conversation.conversationName = self.createConversationName(members)
            conversation.coverCode = ""
            //Default conversation isUnlocked
            conversation.isLocked = 0
            let dateformater = NSDateFormatter.ISO8601DateFormatter()
            conversation.lastMessageTimestamp = dateformater.stringFromDate(NSDate())
            
            do{
                try managedContext.save()
                ConversationObserver.observer.conversationCreate(conversation)
                
                return conversation
            }catch{
            
            }
            
        }
        return Conversation()
    }
    
    /**
     Create name of conversation for first tym
     
     Parameter: An array of member in Contact type
     
     Return: Name of convesation in String
     */
    func createConversationName(members: [Contact])->String{
        var name: String = ""
        if members.count > 2 {
            // Load first 2 people name, the rest with will be ignore and add number
            for eachMember in 0..<2{
                let firstName = members[eachMember].firstName!
                name = "\(name), \(firstName)"
            }
            
            // Remove the ',' and ' ' in the string
            name.removeAtIndex(name.startIndex)
            name.removeAtIndex(name.startIndex)
            let numOfpeople = " and ... (\(members.count+1))"
            name.appendContentsOf(numOfpeople)
        }else{
            for eachMember in members{
                let firstName = eachMember.firstName!
                name = "\(name), \(firstName)"
            }
            
            // Remove the ',' and ' ' in the string
            name.removeAtIndex(name.startIndex)
            name.removeAtIndex(name.startIndex)
            let numOfpeople = "(\(members.count+1))"
            name.appendContentsOf(numOfpeople)
        }
        
        
        
        return name
    }
    
    /**
     Get conversation based on conversation ID
     
     Parameter: conversation ID
     
     Return: String
     */
    func getConversationName(conversationID: String) -> String{
        
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        fetchRequest.propertiesToFetch = ["conversationName"]
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.predicate = NSPredicate(format: "conversationID = %@", conversationID)
        fetchRequest.fetchLimit = 1
        do{
            if let result = try managedContext.executeFetchRequest(fetchRequest) as? [[String:AnyObject]] {
                return result[0]["conversationName"] as! String
            }
        }catch{
            print(error)
        }
        return ""
    }
    
    
    
    /**
     Delete particular conversation and its conversationID in Firebase (conversationMember)
     
     Parameter: conversation ID
     
     Return: String
     */
    func deleteConversation(conversationID: String){
        let getConversationRequest = NSFetchRequest(entityName: "Conversation")
        getConversationRequest.predicate = NSPredicate(format: "conversationID = %@", conversationID)
        var conversation: Conversation?
        do{
            conversation = try managedContext.executeFetchRequest(getConversationRequest).first as? Conversation
            
            if conversation?.type == ConversationType.Group.rawValue {
                ConversationObserver.observer.deleteGroupConversationID(conversation!.conversationID!)
            }
            ConversationObserver.observer.deleteConversationFromUser(conversation!.conversationID!)
            managedContext.deleteObject(conversation!)
            try managedContext.save()
        }catch{}
        
        
    }
    
    /**
      Delete all conversations from Core Data & conversationID from Firebase (conversationMember)
     */
    func deleteAllConversations(){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                do{
                    let conversationList = self.getAllConversationList()
                    for conversation in conversationList{
                        ConversationObserver.observer.deleteConversationFromUser(conversation.conversationID!)
                        self.managedContext.deleteObject(conversation)
                    }
                    try self.managedContext.save()
                }catch{}
            }
        }
    }
    
    /**
     Do predicate search for Recently  Chat
     
     Parameter: Key word for seaching
     
     Return: An array of dictionary consist of conversationID, conversationName, conversationPhotoPath, type
     */
    func searchResult(str: String)->[[String:AnyObject]]{
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
        

        do{
            // Get the conversation list from Core Data and filter it using the name
            let fetchRequest = NSFetchRequest(entityName: "Conversation")
            fetchRequest.predicate = predicate
            fetchRequest.propertiesToFetch = ["conversationID","conversationName", "conversationPhotoPath", "type"]
            fetchRequest.resultType = .DictionaryResultType
            
            // Sorted by conversationName, members.lastName, members.firstName
            let conversationList = try managedContext.executeFetchRequest(fetchRequest) as? [[String:AnyObject]]

            return conversationList!
        }catch{}
        return []
    }
    
    
    /**
     Store the message to CoreData and Firebase
     */

    func sendMessage(msg: String, conversationID: String, isCover: Bool)-> Message{
        
        let conversation = self.getConversation(conversationID)
        
        if let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedContext) as? Message{
            message.type = MessageType.NormalMessage.rawValue
            message.content = "\(msg)   "
            
            let dateFormatter = NSDateFormatter.ISO8601DateFormatter()
            
            message.senderID = FIRAuth.auth()?.currentUser?.uid
            message.conversation = conversation
            //Revert the format same as the format will send to Firebase
            message.sentDate = dateFormatter.dateFromString( dateFormatter.stringFromDate( NSDate()) )
            let dateformater = NSDateFormatter.ISO8601DateFormatter()
            conversation.lastMessageTimestamp = dateformater.stringFromDate(NSDate())
            
            if isCover {
                message.shouldCover = 1
            }else{
                message.shouldCover = 0
            }
            
            do {
                try managedContext.save()
                ConversationObserver.observer.sendMessage(conversation, message: message)
            }catch{
                print("Error saving new message")
            }
            return message
        }
        return Message()
    }
    
    /**
     Store the message consist of image to CoreData and Firebase
     */

    func sendMessageImage(img: UIImage, conversationID: String, isCover: Bool)-> Message{
        
        let conversation = self.getConversation(conversationID)
        
        
        
        // Save the image first
        // save img to Document Directory
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_ddHHmm"
        let imgName = "\(dateFormatter.stringFromDate(NSDate())).png"
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = documentPath[0]
        let url = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(imgName)
        if let data = UIImagePNGRepresentation(img){
            data.writeToURL(url, atomically: true)
            print("Success save image to\n\(url)")
        }

        let attachment = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: managedContext) as! Attachment
        
        attachment.sentDate = NSDate()
        attachment.filePath = imgName
        
        do {
            
            try managedContext.save()
        }catch{
            do{
                let fileManager = NSFileManager.defaultManager()
                try fileManager.removeItemAtURL(url)
            }catch{
                
                print("Failure to delete image")
            }
            print("Failure to save attachment")
            return Message()
        }
        
        // if success
        if let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedContext) as? Message{
            
            
            attachment.message = message
            message.type = MessageType.Image.rawValue
            message.attachements = NSSet(array: [attachment])
            message.senderID = FIRAuth.auth()?.currentUser?.uid
            message.conversation = conversation
            message.sentDate = NSDate()
            
            let dateformater = NSDateFormatter.ISO8601DateFormatter()
            conversation.lastMessageTimestamp = dateformater.stringFromDate(NSDate())
            
            if isCover {
                message.shouldCover = 1
            }else{
                message.shouldCover = 0
            }
            
            do {
                try managedContext.save()
                ConversationObserver.observer.sendMessage(conversation, message: message)
            }catch{
                print("Error saving new message")
            }
            return message
        }
        return Message()
    }
    
    /**
     Store the message of Share Location to CoreData and Firebase
     */
    func sendMessageMap(img:UIImage, conversationID: String, isCover: Bool, lat: String, lon: String)-> Message{
        
        
        let conversation = self.getConversation(conversationID)
        
        
        // Save the image first
        // save img to Document Directory
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_ddHHmm"
        let imgName = "\(dateFormatter.stringFromDate(NSDate())).png"
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = documentPath[0]
        let url = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(imgName)
        if let data = UIImagePNGRepresentation(img){
            data.writeToURL(url, atomically: true)
            print("Success save image to\n\(url)")
        }
        
        let attachment = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: managedContext) as! Attachment
        
        attachment.sentDate = NSDate()
        attachment.filePath = imgName
        
        do {
            
            try managedContext.save()
        }catch{
            do{
                let fileManager = NSFileManager.defaultManager()
                try fileManager.removeItemAtURL(url)
            }catch{
                
                print("Failure to delete image")
            }
            print("Failure to save attachment")
            return Message()
        }

        // if success
        if let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedContext) as? Message{
            message.attachements = [attachment]
            message.type = MessageType.Map.rawValue
            message.content = "\(lat), \(lon)"
            message.senderID = FIRAuth.auth()?.currentUser?.uid
            message.conversation = conversation
            message.sentDate = NSDate()
            
            
            let dateformater = NSDateFormatter.ISO8601DateFormatter()
            conversation.lastMessageTimestamp = dateformater.stringFromDate(NSDate())
            
            if isCover {
                message.shouldCover = 1
            }else{
                message.shouldCover = 0
            }
            
            do {
                try managedContext.save()
                ConversationObserver.observer.sendMessage(conversation, message: message)
            }catch{
                print("Error saving new message")
            }
            return message
        }
        return Message()
    }
    
    /**
     Get the message based on the number of limit
     
     Parameter: number of limit of meesage need to query, conversation ID
     
     Return: an array of Message
     */
    func getMessage(limit: Int, conversationID: String)->[Message]{
        let fetchRequest = NSFetchRequest(entityName: "Message")
        fetchRequest.predicate = NSPredicate(format: "conversation.conversationID = %@", conversationID)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sentDate", ascending: false)]
        fetchRequest.fetchLimit = limit
        
        do{
            if let getMessageList = try managedContext.executeFetchRequest(fetchRequest) as? [Message]{
                let getMessageListSorted = getMessageList.sort({ (msg1, msg2) -> Bool in
                    
                        let date1 = msg1.sentDate
                        let date2 = msg2.sentDate
                        
                        return date1?.compare(date2!) == NSComparisonResult.OrderedAscending
                })
                return getMessageListSorted
            }
        }catch{}
        
        return []
    }
    
    
    /**
     Get the to know the particular conversation isLocked or not
     
     Parameter: conversation ID
     
     Return: Int
     */
    func getIsLocked(conversationID:String)-> Int{
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        fetchRequest.propertiesToFetch = ["isLocked"]
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "conversationID = %@", conversationID)
        do{
            if let result = try managedContext.executeFetchRequest(fetchRequest) as? [[String:AnyObject]]{
                return result[0]["isLocked"] as! Int
            }
        }catch{
            print(error)
        }
        
        return 0

    }
    
    /**
     Get the coverCode of conversation
     
     Parameter: conversation ID
     
     Return: Int
     */
    func getCoverCode(conversationID: String)->String{
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        fetchRequest.propertiesToFetch = ["coverCode"]
        fetchRequest.resultType = .DictionaryResultType
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "conversationID = %@", conversationID)
        do{
            if let result = try managedContext.executeFetchRequest(fetchRequest) as? [[String:AnyObject]]{
                return result[0]["coverCode"] as! String
            }
        }catch{
            print(error)
        }
        
        return ""

    }
    
    
    // MARK: -Contact
    /**
     Get a list of contact
     */
    func getContactList()->[Contact]{
        
        let getContactRequest = NSFetchRequest(entityName: "Contact")
        let firstNameSort = NSSortDescriptor(key: "firstName", ascending: true)
        getContactRequest.sortDescriptors = [firstNameSort]
        getContactRequest.predicate = NSPredicate(format: "status = %@", ContactStatus.Added.rawValue)
        do{
            if let getContactList = try managedContext.executeFetchRequest(getContactRequest) as? [Contact]{
                return getContactList
            }
        }catch{}
        return []
    }
    
    /**
     Search a list of contact
     
     Parameter: Key word
     
     Return: An array of Contact
     */
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
    
    
}
