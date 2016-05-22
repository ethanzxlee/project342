//
//  ChatRoomViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ChatRoomViewController: UITableViewController{
    let managedContent = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var message: Message?
    var conversation: Conversation?
        override func viewDidLoad() {
            super.viewDidLoad()
            let path = Firebase(url: "https://fiery-fire-3992.firebaseio.com/conversations/-KILrzoi04AK_0N65P_m")
            path.authUser("9w2owd@gmail.com", password: "123456789/") { (error, authData) in}
            
            path.observeEventType(.Value, withBlock: { snapshot in
                let attchmentList = snapshot.value.objectForKey("item") as! String

                let imgData = NSData(base64EncodedString: attchmentList, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                let img = UIImage(data: imgData)
                let viewImg = UIImageView()
                viewImg.image = img
                viewImg.center = self.view.center
                self.view.addSubview(viewImg)
                },
                withCancelBlock: { error in
                    print(error.description)
                }
            )

            
            
//            let attachment2 = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: managedContent) as! Attachment
//                        attachment2.filePath = "pic.png"
//            
//                        attachment2.sentDate = NSDate()
//                        attachment2.message = message
//
//            path.setValue(attachment2.dictionary())
            
//        let path = Firebase(url: "https://fiery-fire-3992.firebaseio.com")
//        path.authUser("9w2owd@gmail.com", password: "123456789/") { (error, authData) in}
//        let postPath = path.childByAppendingPath("conversations")
//        let pathRefrecence = postPath.childByAutoId()
//            message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedContent) as? Message
//            conversation = NSEntityDescription.insertNewObjectForEntityForName("Conversation", inManagedObjectContext: managedContent) as? Conversation
//
//        let attachment = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: managedContent) as! Attachment
//            attachment.filePath = "pic.png"
//            attachment.sentDate = NSDate()
//            attachment.message = message
//        
//            
//            let attachment2 = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: managedContent) as! Attachment
//            attachment2.filePath = "pic.png"
//            
//            attachment2.sentDate = NSDate()
//            attachment2.message = message
//            
//        message?.content = "dddddd"
//        message?.conversation = conversation
//            message?.sentDate = NSDate()
//            message?.shouldCover = true
//            message?.attachements = NSSet(array: [attachment2, attachment])
//        conversation?.messages = NSSet(array: [message!])
//            print(message?.sentDate)
//
//            pathRefrecence.setValue(attachment2.dictionary())
//            print(pathRefrecence.authData.uid)
//            print(pathRefrecence.authData)
//            print(pathRefrecence)
//
////            let arry =  pathRefrecence.description.componentsSeparatedByString("/-")
//            
//            let getData = path.childByAppendingPath("conversations")
//            .childByAppendingPath("-KILecpezSfOFTP7zPEH")
//            .childByAppendingPath("attachments")
//            
//            getData.observeEventType(.Value, withBlock: { snapshot in
//                let attchmentList = snapshot.value as! [NSDictionary]
////                for eachAtt in attchmentList{
////                    
////                }
////                print(attchmentList[0].sentDate)
//                },
//                withCancelBlock: { error in
//                    print(error.description)
//                }
//            )
//            
//            let getData2 = path.childByAppendingPath("conversations")
//                .childByAppendingPath("-KILecpezSfOFTP7zPEH")
//            
//            getData2.observeEventType(.Value, withBlock: { snapshot in
//                let info = snapshot.value.objectForKey("content") as! String
//                print(info)
//                
//                },
//                                     withCancelBlock: { error in
//                                        print(error.description)
//                }
//            )
//
//
//            
//            print("w")
            
            
            
//            let postRef = ref.childByAppendingPath("posts")
//            let post1 = ["author": "gracehop", "title": "Announcing COBOL, a New Programming Language"]
//            let post1Ref = postRef.childByAutoId()
//            post1Ref.setValue(post1)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Segue
    @IBAction func backFromAttachmentView(sender: UIStoryboardSegue){}
    
    

}