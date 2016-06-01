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
import QuartzCore
import CoreLocation
import AVFoundation
import MapKit
import LocalAuthentication

class ChatRoomViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate{
        
    @IBOutlet weak var shareLocationButton: UIButton!                           // For Share Location
    
    @IBOutlet weak var textView: UITextView!                                    // Field to enter the content of message
    
    @IBOutlet weak var hiddenButton: UIButton!                                  // Button to start hidden msg feature
    
    @IBOutlet weak var sendButton: UIButton!                                    // Button to send msg
    
    @IBOutlet weak var chatContentTableView: UITableView!                       // Table View show conversation
    
    @IBOutlet weak var contentView: UIView!                                     // Overall View that consist of TableView, TextView for enter message, and so on
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var messageContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageContentViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func multiSelectionButtonFunc(sender: AnyObject) {
        self.textView.resignFirstResponder()
        
        let alertDialog = UIAlertController()
        
        let takePhotoVideoAction = UIAlertAction(title: "Take Photo/Video", style: .Default) { (_) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .Camera
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let choosePhotoVideoAction = UIAlertAction(title: "Choose Photo/Video", style: .Default){(_) in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertDialog.addAction(cancelAction)
        alertDialog.addAction(takePhotoVideoAction)
        alertDialog.addAction(choosePhotoVideoAction)
        self.presentViewController(alertDialog, animated: true, completion: nil)
        
    }
    
    @IBAction func shareLocationButtonFunc(sender: AnyObject) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    @IBAction func hiddenButtonFunc(sender: AnyObject) {
        if self.hiddenMessageSign {
            self.hiddenMessageSign = false
            self.contentView.backgroundColor = UIColor.lightGrayColor()
        }else{
            self.hiddenMessageSign = true
            self.contentView.backgroundColor = UIColor.blackColor()
        }
    }
    
    @IBAction func sendButtonFunc(sender: AnyObject) {
        if self.textView.text != "" {
            let messsge = self.appModel.sendMessage(self.textView.text, conversationID:  self.conversationID!, isCover: self.hiddenMessageSign)
            if messsge.sentDate != nil {
                messagesDisplay.append(messsge)
            }
            self.textView.text = ""

            self.addRowToTableView()
            self.textView.resignFirstResponder()
        }
        sendButton.hidden = true
        shareLocationButton.hidden = false
        hiddenButton.hidden = false
        adjustTextViewHeight()
    }
    
    var imagePicker = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    
    var hiddenMessageSign = false
    
    let appModel = AppModel()
        
    var conversationID : String?
    
    var messagesDisplay : [Message] = []
    
    var secretViewer: SecretMessageViewController?
    
    var attachmentViewer: AttachmentViewerViewController?
    
    var constraint = NSLayoutConstraint()
    
    var location: CLLocationCoordinate2D?
    
    var firstTimeViewSecret = 1  // Detect user first tym to see the secret message or not; 1: Yes, 0:No
    
    var isLocked = 0  // Detect user lock the conversation or not; 1: Yes, 0:No
    
    
    
    // Set the number of loading needed for query data from core data
    // Set the default values needed add for the increasing of number of loading
    var numberOfLoading = 1
    let defaultLimit = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstTimeViewSecret = 1
        
        isLocked = self.appModel.getIsLocked(conversationID!)
        
        if isLocked == 1{
            self.authenticateUserForConversation()
        }
        else{
            isLocked = 0
            self.emptyView.removeFromSuperview()
        }
        
        self.title = self.appModel.getConversationName(conversationID!)
        
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 5
        
        
        self.locationManager.delegate = self
        

        self.chatContentTableView.registerNib(UINib(nibName: "RightChatRoomCustomCell", bundle: nil), forCellReuseIdentifier: "rightChatRoomCell")
        
        self.chatContentTableView.registerNib(UINib(nibName: "LeftChatRoomCustomCell", bundle: nil), forCellReuseIdentifier: "leftChatRoomCell")
        
        self.chatContentTableView.rowHeight = UITableViewAutomaticDimension
        self.chatContentTableView.estimatedRowHeight = 300
        
        self.imagePicker.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatRoomViewController.tapGestureFunc))
        self.view.addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ChatRoomViewController.viewSecretMessage))
        self.chatContentTableView.addGestureRecognizer(longPressGesture)
        let tapGestureCell = UITapGestureRecognizer(target: self, action: #selector(ChatRoomViewController.tapGestureCellFunc))
        self.chatContentTableView.addGestureRecognizer(tapGestureCell)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        messagesDisplay = self.appModel.getMessage(defaultLimit * numberOfLoading, conversationID: conversationID!)
        numberOfLoading += 1
        
        // TODO:Delete below unwanted part
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let message1 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        let message2 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        
        message1.content = "hello world. It is so fucking cold a=even though i just open a small gap of my door. The wind still flow from my living room to my bed room. What the fuck. This is so fuck. I just have one day to do 342 project. Tmr i still need to do revision for my quiz meanwhile I have touch my 321 documentation."

        message2.content = "hello world. It is so fucking cold a=even though i just open a small gap of my door. The wind still flow from my living room to my bed room. What the fuck. This is so fuck. I just have one day to do 342 project. Tmr i still need to do revision for my quiz meanwhile I have touch my 321 documentation."
        message2.shouldCover = 1
         message1.shouldCover = 0
        messagesDisplay.append(message1)
        messagesDisplay.append(message2)
        message1.senderID="1234"
        message2.senderID="888"
        let message3 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        let message4 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        
        message3.content = "hello world.\nhello world.\nwhy right s"
        
        message4.content = "hello "
        
        message3.senderID="888"
        message4.senderID="888"
        
        messagesDisplay.append(message3)
        messagesDisplay.append(message4)
        
        let message5 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        let message6 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        
        message6.content = "hello world.\nhello world.\nwhy right"
        
        message5.content = "ht  "
        
        
        message5.senderID="1234"
        message6.senderID="888"
        
        messagesDisplay.append(message5)
        messagesDisplay.append(message6)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToAttachmentView"{
            if let goToNavigationController = segue.destinationViewController as? UINavigationController {
                if let destination = goToNavigationController.topViewController as? AttachmentViewerViewController{
                    destination.message = sender as? Message
                }
            }
        }
    }
    

    // MARK: TextView
    func textViewDidChange(textView: UITextView) {
        if textView.text == "" {
            sendButton.hidden = true
            shareLocationButton.hidden = false
            hiddenButton.hidden = false
        }else{
            sendButton.hidden = false
            shareLocationButton.hidden = true
            hiddenButton.hidden = true
        }
        adjustTextViewHeight()
       
    }
    
    func adjustTextViewHeight(){
        var adjustment = textView.bounds.size.height - textView.contentSize.height
        if adjustment < 0 {
            adjustment = 0
        }
        
        textView.contentOffset = CGPoint(x: 0, y: -adjustment)
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.max))
        if newSize.height > 30 {
            messageContentViewHeightConstraint.constant = newSize.height
        }
    }
    
    // MARK: Keyboard Notification
    func keyboardWillShow(notification: NSNotification){
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue){
            let keyboardHeight = keyboardSize.CGRectValue().height
            
            messageContentViewBottomConstraint.constant += keyboardHeight
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue){
            let keyboardHeight = keyboardSize.CGRectValue().height
            
            messageContentViewBottomConstraint.constant -= keyboardHeight
            
        }
    }
    
    // MARK: Segue
    @IBAction func backFromAttachmentView(sender: UIStoryboardSegue){}
    
    // MARK: Location & Share Location feature
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.locationManager.stopUpdatingLocation()
        self.location = location!.coordinate
        self.shareLocation()
    }
    
    func shareLocation(){
        let newFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let map = MKMapView(frame: newFrame)
        let regionRadius : CLLocationDistance = 200

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.location!, regionRadius*2, regionRadius*2)
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
            var point = snapshot.pointForCoordinate(self.location!)
            
            let rect = CGRect(origin: CGPoint.zero, size: img.size)
            if rect.contains(point){
                
                point.x = point.x + dropPin.centerOffset.x - (dropPin.bounds.size.width/2)
                point.y = point.y + dropPin.centerOffset.y - (dropPin.bounds.size.height/2)
                dropPin.image?.drawAtPoint(point)
            }
            
            let mapPin = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let msg = self.appModel.sendMessageMap(mapPin, conversationID: self.conversationID!, isCover: self.hiddenMessageSign, lat: self.location!.latitude.description, lon: self.location!.longitude.description)
            self.messagesDisplay.append(msg)
            self.addRowToTableView()
        }

    }
    
    
    // MARK: ImagePicker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
  
        if let imgSelected = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let message = self.appModel.sendMessageImage(imgSelected, conversationID: self.conversationID!, isCover: self.hiddenMessageSign)
            self.messagesDisplay.append(message)
            self.dismissViewControllerAnimated(true, completion: nil)

            self.addRowToTableView()
            
            
            
        }
   
        
//        // TODO: Do something to send video url
//        if let video = info[UIImagePickerControllerMediaURL] as? NSURL{
//            
//        }
    }
    
    // MARK: TableView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDisplay.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let userInfo = NSUserDefaults()
        userInfo.setObject("wko232", forKey: "userID")
        userInfo.setObject("coverCode", forKey: "coverCode")
        let userID = userInfo.stringForKey("userID")
        if messagesDisplay[indexPath.row].senderID != userID! {
            
            
            // MARK: User Receive Message
            let cell = tableView.dequeueReusableCellWithIdentifier("leftChatRoomCell", forIndexPath: indexPath) as! LeftChatRoomCustomCell
            
            // If cover message
            // FIXME: get cover code from NSUSERdefault??
            if messagesDisplay[indexPath.row].shouldCover == 1{
                cell.messageContent.text = userInfo.stringForKey("coverCode")
                cell.messageContent.sizeToFit()
                return cell
            }
            
            
            // Check for display avatar
            if indexPath.row != 0 {
                if messagesDisplay[indexPath.row].senderID == messagesDisplay[indexPath.row-1].senderID{
                    cell.profileView.hidden = true
                }else{
                    cell.profileView.hidden = false
                }
            }
            
            let type = messagesDisplay[indexPath.row].type!
            print(type)
            if type == MessageType.NormalMessage.rawValue {
                cell.imageView!.image = nil
                cell.messageContent.text = self.messagesDisplay[indexPath.row].content
                cell.messageContent.sizeToFit()
            }else if type == MessageType.Image.rawValue || type == MessageType.Map.rawValue{
                let attachments = self.messagesDisplay[indexPath.row].attachements!.allObjects as! [Attachment]
                let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentDirectory = documentPath[0]
                
                // Crop the image
                let img = UIImage(named: "\(documentDirectory)/\(attachments[0].filePath!)")!
                var cropRect = CGRectMake(0, 0, img.size.width, img.size.height)
                if img.size.height > 300 {
                    cropRect = CGRectMake(img.size.width/4, img.size.height/4, 200, 200)
                }
                let cgImage = CGImageCreateWithImageInRect(img.CGImage, cropRect)
                
                // Put the image as attchment and put into uilabel
                let attachmentLabel = NSTextAttachment()
                attachmentLabel.image = UIImage(CGImage: cgImage!)
                
                let stringWithImg = NSAttributedString(attachment: attachmentLabel)
                
                let attributedString = NSMutableAttributedString(string: "Preview\n ")
                attributedString.replaceCharactersInRange(NSMakeRange(8, 1), withAttributedString: stringWithImg)
                
                cell.messageContent.attributedText = attributedString
                
            }else{
                print("Error Message of Attachments/Messages from core data")
            }
            
            
            return cell
        }else{
            // MARK: User Send Message
            let cell = tableView.dequeueReusableCellWithIdentifier("rightChatRoomCell", forIndexPath: indexPath) as! RightChatRoomCustomCell
            
            
            // If cover message
            // FIXME: get cover code from NSUSERdefault??
            if messagesDisplay[indexPath.row].shouldCover == 1{
                cell.messageContent.text = userInfo.stringForKey("coverCode")
                cell.messageContent.sizeToFit()
                return cell
            }
            
            // Check for display avatar
            if indexPath.row != 0 {
                if messagesDisplay[indexPath.row].senderID == messagesDisplay[indexPath.row-1].senderID{
                    cell.profileView.hidden = true
                }else{
                    cell.profileView.hidden = false
                }
            }
            
            let type = messagesDisplay[indexPath.row].type!
            print(type)
            if type == MessageType.NormalMessage.rawValue {
                cell.imageView!.image = nil
                cell.messageContent.text = self.messagesDisplay[indexPath.row].content
                cell.messageContent.sizeToFit()
            }else if type == MessageType.Image.rawValue || type == MessageType.Map.rawValue{
                let attachments = self.messagesDisplay[indexPath.row].attachements!.allObjects as! [Attachment]
                let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentDirectory = documentPath[0]
                
                // Crop the image
                let img = UIImage(named: "\(documentDirectory)/\(attachments[0].filePath!)")!
                var cropRect = CGRectMake(0, 0, img.size.width, img.size.height)
                if img.size.height > 300 {
                    cropRect = CGRectMake(img.size.width/4, img.size.height/4, 200, 200)
                }
                let cgImage = CGImageCreateWithImageInRect(img.CGImage, cropRect)
                
                // Put the image as attchment and put into uilabel
                let attachmentLabel = NSTextAttachment()
                attachmentLabel.image = UIImage(CGImage: cgImage!)
                
                let stringWithImg = NSAttributedString(attachment: attachmentLabel)
                
                let attributedString = NSMutableAttributedString(string: "Preview\n ")
                attributedString.replaceCharactersInRange(NSMakeRange(8, 1), withAttributedString: stringWithImg)
                
                cell.messageContent.attributedText = attributedString

            }else{
                print("Error Message of Attachments/Messages from core data")
            }

            
            return cell
        }
    }
    
    func addRowToTableView(){
        self.chatContentTableView.beginUpdates()
        self.chatContentTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messagesDisplay.count-1, inSection:0)] , withRowAnimation: UITableViewRowAnimation.Automatic)
        self.chatContentTableView.endUpdates()
        
        self.chatContentTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messagesDisplay.count-1, inSection:0), atScrollPosition: .Middle, animated: true)
    }

    // MARK: Gesture
    func tapGestureFunc(){
        self.textView.resignFirstResponder()
    }
    
    func tapGestureCellFunc(gesture: UITapGestureRecognizer){
        let locationInView = gesture.locationInView(self.chatContentTableView)
        let indexPath = self.chatContentTableView.indexPathForRowAtPoint(locationInView)
        guard let _indexPath = indexPath else{
            return
        }
        
        if messagesDisplay[_indexPath.row].shouldCover == 0{
            self.performSegueWithIdentifier("goToAttachmentView", sender: messagesDisplay[_indexPath.row])
        }
    }
    
    func longPressGestureFunc(longPressGestureRecognizer: UILongPressGestureRecognizer){
       
        let locationInView = longPressGestureRecognizer.locationInView(self.chatContentTableView)
        let indexPath = self.chatContentTableView.indexPathForRowAtPoint(locationInView)
        guard let _indexPath = indexPath else{
            return
        }
        switch (longPressGestureRecognizer.state) {
        case .Began:
            print("Began")
                secretViewer = self.storyboard?.instantiateViewControllerWithIdentifier("SecretMessageViewController")as? SecretMessageViewController
                secretViewer?.msg = messagesDisplay[_indexPath.row]
                
                guard let _secretViewer = secretViewer else{
                    return
                }
                
                self.addChildViewController(_secretViewer)
                _secretViewer.view.frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width-20, height: self.view.frame.size.height/2)
                _secretViewer.view.center = self.view.center

                self.view.addSubview(_secretViewer.view)
                _secretViewer.didMoveToParentViewController(self)

            
        case .Cancelled:
            print("Cancelled")
        case .Changed:
            print("Changed")
        case .Ended:
            print("Ended")
            
                guard let _secretViewer = secretViewer else {
                    return
                }
                
                _secretViewer.view.removeFromSuperview()
                _secretViewer.removeFromParentViewController()
    
            
            
        case .Failed:
            print("Failed")
        case .Possible:
            print("Possible")
        }

    }
    
    // MARK: TouchID authenticate
    func viewSecretMessage(longPressGestureRecognizer: UILongPressGestureRecognizer){
        let locationInView = longPressGestureRecognizer.locationInView(self.chatContentTableView)
        let indexPath = self.chatContentTableView.indexPathForRowAtPoint(locationInView)
        guard let _indexPath = indexPath else{
            return
        }
        let msgIsCover = messagesDisplay[_indexPath.row].shouldCover
        if msgIsCover == 0{
            return
        }
        if firstTimeViewSecret == 1{
            
            let context = LAContext()
            
            var error: NSError?
            
            let reasonToldUser = "Authentication is needed to access your chipher message. After matching, Long Press the message again to see the content."
            
            // check the device can support or not
            if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
                context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonToldUser, reply: { (success, errorPolicy) in
                    if success{
                        self.firstTimeViewSecret = 0
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), { 
                            dispatch_async(dispatch_get_main_queue(), { 
                                self.successAlert("Password matched. You able to see the secret message by Long Press feature.")
                            })
                        })

                    }else{
                        switch (errorPolicy!.code){
                        case LAError.SystemCancel.rawValue:
                            print("Authentication was cancelled by system")
                            break
                        case LAError.UserCancel.rawValue:
                            print("Authentication was cancelled by user")
                            break
                        case LAError.UserFallback.rawValue:
                            print("User would like to enter the password")
                            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                                dispatch_async(dispatch_get_main_queue(), {
                                        self.showAuthenticationPasswordAlert("Please type the password to access the secret message.")
                                    })
                                })
                            break
                        default:
                            print("Authentication Failed")
                            break
                        }
                    }
                })
            }else{
                self.showAuthenticationPasswordAlert("Press enter the password to access the secret message before Long Press to view the message.")
            }
        }else{
            self.longPressGestureFunc(longPressGestureRecognizer)
        }
    }
    
    func authenticateUserForConversation(){
        let context = LAContext()
        
        var error: NSError?
        
        let reasonToldUser = "Authentication is needed to access the conversation"
        
        // check the device can support or not
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonToldUser, reply: { (success, errorPolicy) in
                if success{
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.emptyView.removeFromSuperview()
                        })
                    })
                    
                }else{
                    switch (errorPolicy!.code){
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by system")
                        break
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by user")
                        break
                    case LAError.UserFallback.rawValue:
                        print("User would like to enter the password")
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                            dispatch_async(dispatch_get_main_queue(), {
                                    self.showAuthenticationPasswordAlert("Please type the password to access the conversation.")
                                })
                            })
                        break
                    default:
                        print("Authentication Failed")
                        break
                    }
                }
            })
        }else{
            self.showAuthenticationPasswordAlert("Press enter the password to access the conversation")
        }
       
    }
    
    
    func showAuthenticationPasswordAlert(msg: String){
        let alertPassword = UIAlertController(title: "Touch ID", message: msg, preferredStyle: .Alert)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let loginAction = UIAlertAction(title: "Login", style: .Default) { (_) in
            let user = NSUserDefaults()
            user.setObject("123456", forKey: "password")
            let password = (alertPassword.textFields![0] as UITextField).text
            if password == user.stringForKey("password"){
                if self.isLocked == 0{
                    self.firstTimeViewSecret = 0
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                        dispatch_async(dispatch_get_main_queue(), {
                                self.successAlert("Password matched. You able to see the secret message by 'Long Press'.")
                        })
                    })

                }else{
                    self.isLocked = 0
                    self.emptyView.removeFromSuperview()
                }
            }else{
                self.showAuthenticationPasswordAlert("Password not matching. Please re-enter the password.")
            }
            
        }
        loginAction.enabled = false
        
        alertPassword.addTextFieldWithConfigurationHandler { (passwordField) in
            passwordField.placeholder = "Login Password"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: passwordField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) in
                loginAction.enabled = passwordField.text != ""
            })
        }
        
        
        alertPassword.addAction(cancelAction)
        alertPassword.addAction(loginAction)
        self.presentViewController(alertPassword, animated: true, completion: nil)
    }
    
    func successAlert(msg: String){
        
        let informAlert = UIAlertController(title: "Information", message: msg, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        informAlert.addAction(cancelAction)
        self.presentViewController(informAlert, animated: true, completion: nil)
    }
    
    
}