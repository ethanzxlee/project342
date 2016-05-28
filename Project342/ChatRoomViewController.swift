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

class ChatRoomViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate{
        
    @IBOutlet weak var microphoneButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var hiddenButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var chatContentTableView: UITableView!
    
    @IBOutlet weak var contentView: UIView!
    
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
        print(messagesDisplay.count)
        
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
        print("dd")
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
        
        cell.messageContent.text = messagesDisplay[indexPath.row].content
        
        cell.messageContent.sizeToFit()
        
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
//            cell.messageContent.backgroundColor = UIColor.init(red: 51/255, green: 1, blue: 153/255, alpha: 1.0)
//        }else{
//            cell.contentLeading.priority = 751
//            cell.contentTrailing.priority = 750
//            cell.profileLeading.priority = 751
//            cell.profileTrailing.priority = 750
//            cell.messageContent.backgroundColor = UIColor.init(red: 102/255, green: 1, blue: 1, alpha: 1.0)
//        }
        
        switch(indexPath.row) {
        case 0:
            cell.contentLeading.priority = 750
            cell.contentTrailing.priority = 751
            cell.profileLeading.priority = 750
            cell.profileTrailing.priority = 751
            cell.messageContent.backgroundColor = UIColor.init(red: 51/255, green: 1, blue: 153/255, alpha: 1.0)
            break
        case 1:
            cell.contentLeading.priority = 751
            cell.contentTrailing.priority = 750
            cell.profileLeading.priority = 751
            cell.profileTrailing.priority = 750
            cell.messageContent.backgroundColor = UIColor.init(red: 102/255, green: 1, blue: 1, alpha: 1.0)
            break
        case 2:
            cell.contentLeading.priority = 750
            cell.contentTrailing.priority = 751
            cell.profileLeading.priority = 750
            cell.profileTrailing.priority = 751
            cell.messageContent.backgroundColor = UIColor.init(red: 51/255, green: 1, blue: 153/255, alpha: 1.0)
            break
        case 3:
            cell.contentLeading.priority = 751
            cell.contentTrailing.priority = 750
            cell.profileLeading.priority = 751
            cell.profileTrailing.priority = 750
            cell.messageContent.backgroundColor = UIColor.init(red: 102/255, green: 1, blue: 1, alpha: 1.0)
            break
        case 4:
            cell.contentLeading.priority = 750
            cell.contentTrailing.priority = 751
            cell.profileLeading.priority = 750
            cell.profileTrailing.priority = 751
            cell.messageContent.backgroundColor = UIColor.init(red: 51/255, green: 1, blue: 153/255, alpha: 1.0)
            break
        case 5:
            cell.contentLeading.priority = 751
            cell.contentTrailing.priority = 750
            cell.profileLeading.priority = 751
            cell.profileTrailing.priority = 750
            cell.messageContent.backgroundColor = UIColor.init(red: 102/255, green: 1, blue: 1, alpha: 1.0)
            break
        default:
            cell.contentLeading.priority = 750
            cell.contentTrailing.priority = 751
            cell.profileLeading.priority = 750
            cell.profileTrailing.priority = 751
            cell.messageContent.backgroundColor = UIColor.init(red: 51/255, green: 1, blue: 153/255, alpha: 1.0)
            break
        }
        
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatRoomCell", forIndexPath: indexPath) as! ChatRoomCustomCell
        
        return cell.messageContent.frame.size.height
    }
    

    
    
    
}