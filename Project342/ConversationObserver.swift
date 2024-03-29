//
//  ConversationObserver.swift
//  Project342
//
//  Created by Fagan Ooi on 31/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import CoreData
import Firebase


class ConversationObserver {
    
    static let observer = ConversationObserver()
    
    
    let managedObjectContext: NSManagedObjectContext
    
    // MARK: Firebase event handles
    
    var conversationChangedEventHandle: FIRDatabaseHandle?
    
    
    private init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    
    // Create the conversation and store its information in Firebase (conversation)
    func conversationCreate(conversation: Conversation){
        let uniID = FirebaseRef.conversationsRef?.childByAutoId().key
        
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            print("No logged in user")
            return
        }
        let conversationDict = conversation.dictionary()
        if conversationDict["type"]as? Int == ConversationType.Group.rawValue {
            if conversationDict["conversationPhotoPath"] as? String != "group.png"{
                let groupProfileURL = Directories.profilePicDirectory?.URLByAppendingPathComponent(conversationDict["conversationPhotoPath"] as! String )
                StorageRef.profilePicRef.child(conversationDict["conversationPhotoPath"] as! String).putFile(groupProfileURL!)
            }
        }
        
        
        FirebaseRef.conversationsRef?.child(uniID!).setValue(conversationDict)
        
        conversation.conversationID = uniID
        do{
            try managedObjectContext.save()
        }catch{
            print("Failure to save conversation ID")
        }
        
        
        
        // Update current user and members involved to
        FirebaseRef.conversationMembersRef?.child(currentUser.uid).updateChildValues([uniID! : uniID!])
        for eachMember in conversation.members?.allObjects as! [Contact]{
            FirebaseRef.conversationMembersRef?.child(eachMember.userId!).updateChildValues([uniID! : uniID!])
        }
        
        FirebaseRef.msgRef?.child(uniID!).setValue(["count" : 0])
    }
    
    // Store message information in Firebase (message) according to conversationID and increase the count
    func sendMessage(conversation: Conversation, message: Message){
        FirebaseRef.msgRef?.child(conversation.conversationID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var count = snapshot.value!["count"] as! Int
            count += 1
            let messageKey = "message\(count)"
            
            // Update 'lastMessageTimestamp" in conversation
            FirebaseRef.conversationsRef?.child(conversation.conversationID!).updateChildValues(["lastMessageTimestamp": (message.sentDate?.description)!])
            
            // Update message
            FirebaseRef.msgRef?.child(conversation.conversationID!).updateChildValues(["count": count])
            if message.type == MessageType.Image.rawValue {
                var dict = message.dictionaryImage()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy_MM_ddHHmm"
                let imgURL = "\(conversation.conversationID!)\(dateFormatter.stringFromDate(NSDate()))"
                
                var attachment = dict["attachments"] as! [String: String]
                
                let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let directory = documentPath[0]
                
                
                let imagePath = NSURL(fileURLWithPath: directory).URLByAppendingPathComponent(attachment["image"]!)

                attachment["image"] = imgURL
                dict["attachments"] = attachment
                StorageRef.imageSendRef.child(imgURL).putFile(imagePath)
                
                FirebaseRef.msgRef?.child(conversation.conversationID!).updateChildValues([messageKey: dict])
            }else{
                
                FirebaseRef.msgRef?.child(conversation.conversationID!).updateChildValues([messageKey: message.dictionaryNormalMessageMap()])
            }
            
        })
        
        // Update the members from Firebase
        let uniID = conversation.conversationID
        FirebaseRef.conversationsRef?.child(conversation.conversationID!).child("membersID").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let membersList = snapshot.value! as! [String: String]
            for eachMember in membersList{
                FirebaseRef.conversationMembersRef?.child(eachMember.0).updateChildValues([uniID! : uniID!])
            }
            
            // Check the list of members been leave to the Core Data
            var membersArray = conversation.members?.allObjects as! [Contact]
            for index in 0..<membersArray.count{
                var isInList = false
                for member in membersList{
                    if member.0 == membersArray[index].userId! {
                        isInList = true
                        return
                    }
                }
                
                if isInList == false {
                    membersArray.removeAtIndex(index)
                }
            }
            
            conversation.members = NSSet(array: membersArray)
            do{
                try self.managedObjectContext.save()
            }catch{
                print("Failure to save conversation ID")
            }

        })
    
    }
    // Delete the reference chat id in Firebase
    func deleteConversationFromUser(conversationID: String){
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            print("No logged in user")
            return
        }
        FirebaseRef.conversationMembersRef?.child(currentUser.uid).child(conversationID).removeValue()
    }
    
    // Delete memberID from conversation in Firebase
    func deleteGroupConversationID(conversationID: String){
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            print("No logged in user")
            return
        }
        FirebaseRef.conversationsRef?.child(conversationID).child("membersID").child(currentUser.uid).removeValue()
    }
    
    // Observe ConversationMember
    func observeConversationMemberEvents() {
        // Remove any existing observer
        stopObservingConversationMemberEvents()
        
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            print("No logged in user")
            return
        }

        conversationChangedEventHandle = FirebaseRef.conversationMembersRef?.child(currentUser.uid).observeEventType(.Value, withBlock: { (snapshot) in
            self.didFirebaseConversationMembersValueChange(snapshot)
        })
    }
    
    // Stop Observe ConversationMember
    func stopObservingConversationMemberEvents() {
        guard
            let conversationChangedEventHandle = conversationChangedEventHandle
            else {
                return
        }
        FirebaseRef.conversationMembersRef?.removeObserverWithHandle(conversationChangedEventHandle)
    }
    
    // Update any information of conversation list in core data based on the Firebase
    private func didFirebaseConversationMembersValueChange(snapshot: FIRDataSnapshot) {
        guard
            let snapshotValues = snapshot.value as? [String: String]
            else {
                return
        }
        
        for conversationID in snapshotValues {
            var conversation: Conversation?
            
            
            // Check if the cxonversation exists
            let fetchRequest = NSFetchRequest(entityName: "Conversation")
            fetchRequest.predicate = NSPredicate(format: "conversationID = %@", conversationID.0)
            
            do {
                conversation = (try managedObjectContext.executeFetchRequest(fetchRequest) as? [Conversation])?.first
            }
            catch {
                print(error)
            }
            
            // Create a new Conversation in CoreData if it doesn't exists
            if conversation == nil {
                conversation = NSEntityDescription.insertNewObjectForEntityForName("Conversation", inManagedObjectContext: managedObjectContext) as? Conversation
            }
            
            
            FirebaseRef.conversationsRef?.child(conversationID.0).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                // Update their statuses
                conversation?.conversationID = conversationID.0
                conversation?.conversationName = snapshot.value!["conversationName"] as? String
                
                
                
                conversation?.type = snapshot.value!["type"] as? Int
                conversation?.lastMessageTimestamp = snapshot.value!["lastMessageTimestamp"] as? String
                
                let memberList = snapshot.value!["membersID"] as? [String:String]

                var memberArray = [Contact]()
                for member in memberList!{
                    let fetchRequest = NSFetchRequest(entityName: "Contact")
                    fetchRequest.predicate = NSPredicate(format: "userId = %@", member.0)

                    do {
                        if let contact = (try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact])?.first {
                            memberArray.append(contact)
                        }
                        
                    }
                    catch {
                        print(error)
                    }

                }
                conversation?.members = NSSet(array: memberArray)
                
                // Save it
                do {
                    try self.managedObjectContext.save()
                }
                catch {
                    print(error)
                }

                
            })
        }
    }
    
    // Observer Conversation
    func observeConversationEvents() {
//        // Remove any existing observer
//        stopObservingConversationEvents()
//
//        let appModel = AppModel()
//        let conversationIDList = appModel.getConversationList(appModel.getConversationMaxRange())
//        
//        for conversation in conversationIDList{
//            let id = conversation["conversationID"] as! String
//            conversationChangedEventHandle = FirebaseRef.conversationsRef?.child(id).observeEventType(.Value, withBlock: { (snapshot) in
//                self.didFirebaseConversationValueChange(snapshot)
//            })
//        }
        
       
    }
    // Stop Observer Conversation
    func stopObservingConversationEvents() {
        guard
            let conversationChangedEventHandle = conversationChangedEventHandle
            else {
                return
        }
        FirebaseRef.conversationMembersRef?.removeObserverWithHandle(conversationChangedEventHandle)
    }
    
    // Update the conversation information based on Firebase
    private func didFirebaseConversationValueChange(snapshot: FIRDataSnapshot) {
        var conversation: Conversation?
        
        
        // Check if the cxonversation exists
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        fetchRequest.predicate = NSPredicate(format: "conversationID = %@", snapshot.key)
        
        do {
            conversation = (try managedObjectContext.executeFetchRequest(fetchRequest) as? [Conversation])?.first
        }
        catch {
            print(error)
        }
        
        // Prevent any empty or meesed data get from Firebase
        if conversation == nil {
            return
        }
    
        // Update their statuses
        
        conversation?.type = snapshot.value!["type"] as? Int
        conversation?.lastMessageTimestamp = snapshot.value!["lastMessageTimestamp"] as? String
        conversation?.conversationPhotoPath = snapshot.value!["conversationPhotoPath"]as? String

        let memberList = snapshot.value!["membersID"] as? [String:String]
        
        var memberArray = [Contact]()
        for member in memberList!{
            let fetchRequest = NSFetchRequest(entityName: "Contact")
            fetchRequest.predicate = NSPredicate(format: "userId = %@", member.0)
            
            do {
                if let contact = (try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact])?.first {
                    memberArray.append(contact)
                }
                
            }
            catch {
                print(error)
            }
            
        }
        conversation?.members = NSSet(array: memberArray)
        
        // Group Photo
        if conversation?.type == ConversationType.Group.rawValue && conversation?.conversationPhotoPath != "group.png"{
            let fileStoreURL = Directories.profilePicDirectory?.URLByAppendingPathComponent(conversation!.conversationPhotoPath!)
            
            let firebaseURL = StorageRef.profilePicRef.child(conversation!.conversationPhotoPath!)
            
            let downloadTask = firebaseURL.writeToFile(fileStoreURL!)
            
            downloadTask.observeStatus(.Success, handler: { (snapshot) in
                print("download img success")
            })
            
        }
        // Personal
        if conversation?.type == ConversationType.Personal.rawValue{
            conversation?.conversationPhotoPath = memberArray[0].userId
        }
        let appModel = AppModel()
        conversation?.conversationName = appModel.createConversationName(memberArray)
        
        // Save it
        do {
            try self.managedObjectContext.save()
        }
        catch {
            print(error)
        }
        
    }

    
}
