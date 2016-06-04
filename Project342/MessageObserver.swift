//
//  MessageObserver.swift
//  Project342
//
//  Created by Fagan Ooi on 01/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//


import CoreData
import Firebase
import MapKit

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
            let dateFormatter = NSDateFormatter.ISO8601DateFormatter()
            let date = dateFormatter.dateFromString(message!["sentDate"] as! String)
            
            print(message)
            print(conversationID)
            print(date)
            // Check if the message exists
            let fetchRequest = NSFetchRequest(entityName: "Message")
            fetchRequest.predicate = NSPredicate(format: "conversation.conversationID = %@ AND sentDate = %@", conversationID, date!)
            
            
            let fetchRequest2 = NSFetchRequest(entityName: "Conversation")
            fetchRequest2.predicate = NSPredicate(format: "conversationID = %@", conversationID)
            var result = 0
            var conversation : Conversation?
            do {
                result = try managedObjectContext.executeFetchRequest(fetchRequest).count
                conversation = (try managedObjectContext.executeFetchRequest(fetchRequest2) as? [Conversation])?.first
            }
            catch {
                print(error)
            }
            // FIXME: result always zero although it appear in core data
            if result == 0 {
                var memberArray = conversation?.messages?.allObjects as! [Message]
                let msg = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedObjectContext) as! Message
                msg.type = message!["type"] as! Int
                if msg.type == MessageType.Image.rawValue || msg.type == MessageType.Map.rawValue {
                    let attachment = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: managedObjectContext) as! Attachment
                    
                    // Create img Path
                    let dateFormatter = NSDateFormatter.ISO8601DateFormatter()
                    let imgName = "\(dateFormatter.stringFromDate(NSDate())).png"
                    
                    let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                    let documentDirectory = documentPath[0]
                    let url = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(imgName)
                    
                    if msg.type == MessageType.Image.rawValue{
                        let attachmentImg = snapshotValues["attachments"]  as! [String:String]
                        let firebaseURL = StorageRef.imageSendRef.child(attachmentImg["image"]!)
                        
                        let downloadTask = firebaseURL.writeToFile(url)
                        
                        downloadTask.observeStatus(.Success, handler: { (snapshot) in
                            print("download img success")
                        })
                        attachment.sentDate = dateFormatter.dateFromString(snapshotValues["sentDate"] as! String)
                    }else{
                        // If it is map, snapshot a picture first
                        let content = message!["content"] as? String
                        let coordinates = content?.componentsSeparatedByString(",")
                        let lat = (coordinates![0] as NSString).doubleValue
                        let lon = (coordinates![1] as NSString).doubleValue
                        
                        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                        
                        
                        let newFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let map = MKMapView(frame: newFrame)
                        let regionRadius : CLLocationDistance = 200
                        
                        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius*2, regionRadius*2)
                        map.setRegion(coordinateRegion, animated: true)
                        
                        let options = MKMapSnapshotOptions()
                        options.region = map.region
                        options.size = map.frame.size
                        options.scale = UIScreen.mainScreen().scale
                        
                        let snapshotter = MKMapSnapshotter(options: options)
                        snapshotter.startWithCompletionHandler { snapshot, error in
                            guard let snapshot = snapshot else {
                                print("Snapshot error: \(error)")
                                return
                            }
                            
                            
                            let dropPin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                            let img = snapshot.image
                            
                            UIGraphicsBeginImageContextWithOptions(img.size, true, img.scale)
                            img.drawAtPoint(CGPoint.zero)
                            var point = snapshot.pointForCoordinate(location)
                            
                            let rect = CGRect(origin: CGPoint.zero, size: img.size)
                            if rect.contains(point){
                                
                                point.x = point.x + dropPin.centerOffset.x - (dropPin.bounds.size.width/2)
                                point.y = point.y + dropPin.centerOffset.y - (dropPin.bounds.size.height/2)
                                dropPin.image?.drawAtPoint(point)
                            }
                            
                            let mapPin = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            if let data = UIImagePNGRepresentation(mapPin){
                                data.writeToURL(url, atomically: true)
                                print("Success save image to\n\(url)")
                            }
                        }
                    }
                    
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

