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

class ChatRoomViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate{
    
    @IBOutlet weak var microphoneButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var chatContentTableView: UITableView!
    
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
        adjustTextViewHeight()
    }
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var messageContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageContentViewHeightConstraint: NSLayoutConstraint!
    
    var recordingSession: AVAudioSession!
    
    var recorder: AVAudioRecorder!
    
    var imagePicker = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    
    var hiddenMessageSign = false
    
    let appModel = AppModel()
    
    var message: Message?
    
    var conversation: Conversation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = conversation?.conversationName!
        
        self.textView.delegate = self
        self.textView.layer.cornerRadius = 5
        
        self.recordingSession = AVAudioSession.sharedInstance()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
self.locationManager.startUpdatingLocation()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRoomViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
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
        }else{
            sendButton.hidden = false
            microphoneButton.hidden = true
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
    
    
    

}