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
        // TODO: Remove this one the login VC is done
        FIRAuth.auth()?.signInWithEmail("9w2owd@gmail.com", password: "password", completion: nil)
    }
    
    func conversationCreate(conversation: Conversation){
        let uniID = FirebaseRef.conversationsRef?.childByAutoId().key
        
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            print("No logged in user")
            return
        }
        
        FirebaseRef.conversationsRef?.child(uniID!).setValue(conversation.dictionary())
        
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
    
    func sendMessage(conversation: Conversation, message: Message){
        FirebaseRef.msgRef?.child(conversation.conversationID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var count = snapshot.value!["count"] as! Int
            count += 1
            let messageKey = "message\(count)"
            
            FirebaseRef.msgRef?.child(conversation.conversationID!).updateChildValues(["count": count])
            if message.type == MessageType.Image.rawValue {
                FirebaseRef.msgRef?.child(conversation.conversationID!).updateChildValues([messageKey: message.dictionaryImage()])
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
    
    func observeConversationEvents() {
        // Remove any existing observer
        stopObservingConversationEvents()
        
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            print("No logged in user")
            return
        }

        conversationChangedEventHandle = FirebaseRef.conversationMembersRef?.child(currentUser.uid).observeEventType(.Value, withBlock: { (snapshot) in
            self.didFirebaseConversationMembersValueChange(snapshot)
        })
    }
    
    func stopObservingConversationEvents() {
        guard
            let conversationChangedEventHandle = conversationChangedEventHandle
            else {
                return
        }
        FirebaseRef.conversationMembersRef?.removeObserverWithHandle(conversationChangedEventHandle)
    }
    
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
                conversation?.coverCode = snapshot.value!["coverCode"] as? String
                conversation?.isLocked = snapshot.value!["isLocked"] as? Int
                let memberList = snapshot.value!["membersID"] as? [String:String]
                var memberArray = [Contact]()
                for member in memberList!{
                    let fetchRequest = NSFetchRequest(entityName: "Contact")
                    fetchRequest.predicate = NSPredicate(format: "userID = %@", member.0)
                    
                    do {
                        let contact = (try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact])?.first
                        memberArray.append(contact!)
                    }
                    catch {
                        print(error)
                    }


                }
                
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
    
}
