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

class ChatRoomViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate{
        
    @IBOutlet weak var microphoneButton: UIButton!                              // For Voice Message
    
    @IBOutlet weak var textView: UITextView!                                    // Field to enter the content of message
    
    @IBOutlet weak var hiddenButton: UIButton!                                  // Button to start hidden msg feature
    
    @IBOutlet weak var sendButton: UIButton!                                    // Button to send msg
    
    @IBOutlet weak var chatContentTableView: UITableView!                       // Table View show conversation
    
    @IBOutlet weak var contentView: UIView!                                     // Overall View that consist of TableView, TextView for enter message, and so on
    
    @IBOutlet weak var messageContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageContentViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func multiSelectionButtonFunc(sender: AnyObject) {
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
        
        let shareLocationAction = UIAlertAction(title: "Share Location", style: .Default) { (_) in
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()

            

        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertDialog.addAction(cancelAction)
        alertDialog.addAction(takePhotoVideoAction)
        alertDialog.addAction(choosePhotoVideoAction)
        alertDialog.addAction(shareLocationAction)
        
        self.presentViewController(alertDialog, animated: true, completion: nil)
        
    }
    
    @IBAction func microphoneButtonFunc(sender: AnyObject) {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        let audioFilename = documentsDirectory.stringByAppendingString("whistle.m4a")
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        do {
            // 5
            recorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            recorder.delegate = self
            recorder.record()
        } catch {

        }
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
            self.appModel.sendMessage(self.textView.text, conversation:  self.conversation!)
            self.textView.text = ""
        }
        sendButton.hidden = true
        microphoneButton.hidden = false
        hiddenButton.hidden = false
        adjustTextViewHeight()
    }
    
    var recordingSession: AVAudioSession!
    
    var recorder: AVAudioRecorder!
    
    var imagePicker = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    
    var hiddenMessageSign = false
    
    let appModel = AppModel()
    
    var message: Message?
    
    var conversation: Conversation?
    
    var img : [UIImage] = []
    
    var messagesDisplay : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = conversation?.conversationName!
        
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 5
        
        self.recordingSession = AVAudioSession.sharedInstance()
        
        self.locationManager.delegate = self
        

        self.chatContentTableView.registerNib(UINib(nibName: "ChatRoomCustomCell", bundle: nil), forCellReuseIdentifier: "chatRoomCell")
        
        self.chatContentTableView.rowHeight = UITableViewAutomaticDimension
        self.chatContentTableView.estimatedRowHeight = 500

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChatRoomViewController.tapGestureFunc))
        self.view.addGestureRecognizer(tapGesture)
        
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let message1 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        let message2 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        
        message1.content = "hello world. It is so fucking cold a=even though i just open a small gap of my door. The wind still flow from my living room to my bed room. What the fuck. This is so fuck. I just have one day to do 342 project. Tmr i still need to do revision for my quiz meanwhile I have touch my 321 documentation."
        
        message2.content = "hello world. It is so fucking cold a=even though i just open a small gap of my door. The wind still flow from my living room to my bed room. What the fuck. This is so fuck. I just have one day to do 342 project. Tmr i still need to do revision for my quiz meanwhile I have touch my 321 documentation."
        
        messagesDisplay.append(message2)
        messagesDisplay.append(message1)
        
        let message3 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        let message4 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        
        message3.content = "hello world.\nhello world.\nwhy right s"
        
        message4.content = "hello "
        
        messagesDisplay.append(message3)
        messagesDisplay.append(message4)
        
        let message5 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        let message6 = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as! Message
        
        message6.content = "hello world.\nhello world.\nwhy right"
        
        message5.content = "hello "
        
        messagesDisplay.append(message5)
        messagesDisplay.append(message6)
        
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
    
    // MARK: TextView
    func textViewDidChange(textView: UITextView) {
        if textView.text == "" {
            sendButton.hidden = true
            microphoneButton.hidden = false
            hiddenButton.hidden = false
        }else{
            sendButton.hidden = false
            microphoneButton.hidden = true
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
        let lat = location?.coordinate.latitude
        let lon = location?.coordinate.longitude
        self.locationManager.stopUpdatingLocation()
        self.shareLocation(lat!, lon: lon!)
    }
    
    
    // TODO: fix how to share in message
    func shareLocation(lat: CLLocationDegrees, lon: CLLocationDegrees){
        
    }
    
    
    // MARK: ImagePicker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let imgSelected = info[UIImagePickerControllerOriginalImage] as? UIImage{
            img.append(imgSelected)
        }
        
        // TODO: Do something to send video url
        if let video = info[UIImagePickerControllerMediaURL] as? NSURL{
            
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("chatRoomCell", forIndexPath: indexPath) as! ChatRoomCustomCell
        
        /**
         Change the priority of contraints according to the message sent by users or the friends
         The constant of Leading and Trailing of label message: 40
         The constant of Leading and Trailing of imageView: 5
         
         The priority will be different will change according to below:
         LEFT SIDE:
         cell.contentLeading.priority = 751
         cell.contentTrailing.priority = 750
         ** The content will move toward left side as the Leading contraint priority is higher
         
         cell.profileLeading.priority = 751
         cell.profileTrailing.priority = 750
         ** The image view will move toward left side as the Leading contraint priority is higher
         
         RIGHT SIDE:
         cell.contentLeading.priority = 750
         cell.contentTrailing.priority = 751
         ** The content will move toward right side as the Trailing contraint priority is higher
         
         cell.profileLeading.priority = 750
         cell.profileTrailing.priority = 751
         ** The image view will move toward right side as the Trailing contraint priority is higher
         */
        
        // TODO: FIXME when merge
//        let userInfo = NSUserDefaults()
//        let userID = userInfo.stringForKey("userID")
//        if messagesDisplay[indexPath.row].senderID == userID!{
//            cell.contentLeading.priority = 750
//            cell.contentTrailing.priority = 751
//            cell.profileLeading.priority = 750
//            cell.profileTrailing.priority = 751
//            cell.attachmentLeading.priority = 750
//            cell.attachmentTrailing.priority = 751
//            cell.messageContent.backgroundColor = UIColor.init(red: 51/255, green: 1, blue: 153/255, alpha: 1.0)
//        }else{
//            cell.contentLeading.priority = 751
//            cell.contentTrailing.priority = 750
//            cell.profileLeading.priority = 751
//            cell.profileTrailing.priority = 750
//            cell.attachmentLeading.priority = 751
//            cell.attachmentTrailing.priority = 750
//            cell.messageContent.backgroundColor = UIColor.init(red: 102/255, green: 1, blue: 1, alpha: 1.0)
//        }
        
        // Content 
//        if message == normal message{
//            cell.messageContent.text = self.messagesDisplay[indexPath.row].content
//            cell.attachmentView.alpha = 0
//        }else if message == mapView {
//        
//            cell.messageContent.alpha = 0;
//            cell.contentView.addConstraint(NSLayoutConstraint(item: cell.contentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 220))
//            // From Friends
//            let newFrame = CGRectMake(cell.attachmentView.frame.minX-40, cell.attachmentView.frame.minY-10, 150, 200)
//            // User send it
//            let newFrame = CGRectMake(cell.attachmentView.frame.minX+120, cell.attachmentView.frame.minY-10, 150, 200)
//
//            let map = MKMapView(frame:newFrame)
//            
//            map.userInteractionEnabled = false
//            cell.attachmentView.alpha = 1
//            cell.attachmentView.addSubview(map)
//
//        }else if message == phot {
//            let img = UIImage(named: "pic.png")
//            let imgView = UIImageView(image: img)
//            imgView.contentMode = .ScaleAspectFit
//            
//            // From Friends
//            imgView.frame = CGRectMake(10, 0, 200, 200)
//            
//            // User send it
//            imgView.frame = CGRectMake(cell.contentView.frame.minX+115, 0, 200, 200)
//            
//            imgView.layer.borderColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
//            imgView.layer.borderWidth = 1
//            imgView.layer.cornerRadius = 7
//            imgView.clipsToBounds = true
//            
//            cell.attachmentView.alpha = 1
//            cell.attachmentView.addSubview(imgView)
//        }
        
        
        //        let newFrame = CGRectMake(0, 0, 100, 100)
////        cell.messageContent.drawRect(CGRect(x: 0, y: 0, width: 200, height: 400))
////        cell.messageContent.sizeToFit()
////        cell.contentView.frame = newFrame
//        cell.messageContent.frame = newFrame
//        cell.attachmentView.frame = newFrame
//        let map = MKMapView()
////        cell.messageContent.drawRect(newFrame)
//        
//      cell.messageContent.addSubview(UIImageView(image: UIImage(named: "pic.png")!))
        cell.attachmentView.alpha = 0
        
                
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatRoomCell", forIndexPath: indexPath) as! ChatRoomCustomCell
        
        return cell.messageContent.frame.size.height
    }
    

    // MARK: Gesture
    func tapGestureFunc(){
        self.textView.resignFirstResponder()
    }
    
    // MARK: MapView
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        let newFrame = CGRectMake(0, 0, 150, 200)
        UIGraphicsBeginImageContext(newFrame.size)
        mapView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let lat = mapView.centerCoordinate.latitude
        let lon = mapView.centerCoordinate.longitude

    }
    
}