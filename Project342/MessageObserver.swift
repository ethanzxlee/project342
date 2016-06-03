//
//  MessageObserver.swift
//  Project342
//
//  Created by Fagan Ooi on 01/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//


import CoreData
import Firebase


class MessageObserver {
    
    static let observer = MessageObserver()
    
    
    let managedObjectContext: NSManagedObjectContext
    
    // MARK: Firebase event handles
    
    var messageChangedEventHandle: FIRDatabaseHandle?
    
    
    private init() {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    // Observe Message
    func observeMessageEvents() {
        // Remove any existing observer
        stopObservingMessageEvents()
        
        let appModel = AppModel()
        let conversationIDList = appModel.getConversationList(appModel.getConversationMaxRange())
        
        for conversation in conversationIDList{
            let id = conversation["conversationID"] as! String
            messageChangedEventHandle = FirebaseRef.msgRef?.child(id).observeEventType(.Value, withBlock: { (snapshot) in
                self.didFirebaseMessageValueChange(snapshot, conversationID: id)
            })
        }
        
    }
    // Stop Observe Message
    func stopObservingMessageEvents() {
        guard
            let messageChangedEventHandle = messageChangedEventHandle
            else {
                return
        }
        FirebaseRef.msgRef?.removeObserverWithHandle(messageChangedEventHandle)
    }
    
    // Update the list of Messages stored in Firebase
    private func didFirebaseMessageValueChange(snapshot: FIRDataSnapshot, conversationID:String) {
        guard
            let snapshotValues = snapshot.value as? [String: AnyObject]
            else {
                return
        }
        
        let count = snapshotValues["count"] as? Int

        
        for index in 0..<count!{
            let key = "message\(index+1)"
            let message = snapshotValues[key] as? [String: AnyObject]
            if message == nil {
                return
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

            let date = dateFormatter.dateFromString(message!["sentDate"] as! String)
            // Check if the message exists
            let fetchRequest = NSFetchRequest(entityName: "Message")
            fetchRequest.predicate = NSPredicate(format: "conversation.conversationID = %@ AND sentDate = %@", conversationID, date!)
            
            
            let fetchRequest2 = NSFetchRequest(entityName: "Conversation")
            fetchRequest2.predicate = NSPredicate(format: "conversationID = %@", conversationID)
            var result = 0
            var conversation : Conversation?
            do {
                result = ((try managedObjectContext.executeFetchRequest(fetchRequest) as? [Message])?.count)!
                conversation = (try managedObjectContext.executeFetchRequest(fetchRequest2) as? [Conversation])?.first
            }
            catch {
                print(error)
            }
            
            if result <= 0 {
                var memberArray = conversation?.messages?.allObjects as! [Message]
                let msg = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedObjectContext) as! Message
                msg.type = message!["type"] as! Int
                if msg.type == MessageType.Image.rawValue {
                    let attachment = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: managedObjectContext) as! Attachment
                    
                    // Create img Path
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy_MM_ddHHmm"
                    let imgName = "\(dateFormatter.stringFromDate(NSDate())).png"
                    
                    let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    let documentDirectory = documentPath[0]
                    let url = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(imgName)
                    
                    if let data = snapshotValues["image"] as? NSData{
                        data.writeToURL(url, atomically: true)
                        print("Success save image to\n\(url)")
                    }
                    
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//                    attachment.sentDate = dateFormatter.dateFromString(snapshotValues["sentDate"] as! String)
                    attachment.filePath = imgName
                    msg.attachements = NSSet(array: [attachment])
                }
                
                
                msg.senderID = message!["senderID"] as? String
                msg.shouldCover = message!["shouldCover"] as? Int
                msg.content = message!["content"] as? String
                print(msg.content)
                msg.sentDate = date
                
                memberArray.append(msg)
                conversation?.messages = NSSet(array: memberArray)
                
                // Save it
                do {
                    try self.managedObjectContext.save()
                }
                catch {
                    print(error)
                }
   
                
                

            }
        }
    }
    
}

