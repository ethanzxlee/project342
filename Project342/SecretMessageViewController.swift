//
//  SecretMessageViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class SecretMessageViewController: UIViewController, AVAudioPlayerDelegate {
    
    /**
     allocate from stakeoverflow.com
     Audio playback progress as UISlider in Swift
     http://stackoverflow.com/questions/29542001/audio-playback-progress-as-uislider-in-swift
     User for: Put the sliders to indicate the amount of length of sound play
     */
    var updaterForProgressSlider : CADisplayLink! = nil
    var progressBarSlider = UISlider()
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var secretMessage: UITextView!
    
    @IBOutlet weak var secretImg: UIImageView!
    
    var msg: Message?
    
    var timer = NSTimer()
    
    let line = CAShapeLayer()
    
    var attachmentIndexShown: Int = 0        // Used to control the transition of image
    
    var audioPlayer : AVAudioPlayer?
    
    var attachmentContentObject = [Attachment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.progressBarSlider.frame.width = self.view.frame.width/2
        self.progressBarSlider.center = self.view.center
        self.view.addSubview(progressBarSlider)
        
        //TODO: MUST DELETE
        loadInitialDataFortry()
        
        // Load the message content into the text view. if it iis empty, hide the view
        // If gt message MEAN it is not voice message
        if msg?.content != "" {
            secretMessage.text = msg?.content
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)){
                dispatch_async(dispatch_get_main_queue()){
                    if self.audioPlayer?.duration <= 0{
                        self.adjustTextViewHeight()
                        self.textViewBorder()
                    }
                }
            }
        }else{
            secretMessage.hidden = true
        }
        
        //Load the image attchement
        attachmentContentObject = msg?.attachements?.allObjects as! [Attachment]
        
        // When it is a voice message, it just has one voice attachment for each message
        if attachmentContentObject.count > 0{
            // Get the filePath form attachement and detect it is voice message or not
            let componentsOfAttachment = attachmentContentObject[0].filePath!.componentsSeparatedByString(".")
            if componentsOfAttachment[componentsOfAttachment.endIndex-1] == "mp3" || componentsOfAttachment[componentsOfAttachment.endIndex-1] == "m4a"{
                let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentDirectory = documentPath[0]
                let destinationPath = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(attachmentContentObject[0].filePath!)
                
                secretImg.removeFromSuperview()
                secretMessage.removeFromSuperview()
                
                playVoiceMessage(destinationPath)
         
            }else{
                // Load the first image before another image continue by using timer
                self.transitionImgAttachment()
                // Load the image by interval timer if consist more than 1 image attachment
                if attachmentContentObject.count > 1{
                    timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(SecretMessageViewController.transitionImgAttachment), userInfo: nil, repeats: true)
                }
            }
        }
        
        if audioPlayer?.duration <= 0 {
            self.progressBarSlider.removeFromSuperview()
        }
        
        
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
    
    // MARK: Text View 
    func adjustTextViewHeight(){
        var adjustment = secretMessage.bounds.size.height - secretMessage.contentSize.height
        if adjustment < 0{
            adjustment = 0
        }
        
        secretMessage.contentOffset = CGPoint(x: 0, y: -adjustment)
        let newSize = secretMessage.sizeThatFits(CGSize(width: secretMessage.frame.size.width, height: CGFloat.max))
        self.textViewHeight.constant = newSize.height
    }
    
    func textViewBorder(){
        
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: self.secretMessage.frame.minX, y: self.secretMessage.frame.maxY+5))
        path.addLineToPoint(CGPoint(x: self.secretMessage.frame.maxX, y: self.secretMessage.frame.maxY+5))
        
        line.path = path.CGPath
        line.strokeColor = UIColor.grayColor().CGColor
        self.view.layer.addSublayer(line)
    }
    
    // MARK: Voice Message
    func playVoiceMessage(path: NSURL){
        
        do{
            updaterForProgressSlider = CADisplayLink(target: self, selector: #selector(SecretMessageViewController.trackVoiceMessage))
            updaterForProgressSlider.frameInterval = 1
            updaterForProgressSlider.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
            
           
            try audioPlayer = AVAudioPlayer(contentsOfURL: path)
            audioPlayer?.numberOfLoops = 0      // -1 if wan infinity loop
            audioPlayer?.delegate = self
            audioPlayer?.play()
    
            progressBarSlider.minimumValue = 0
            progressBarSlider.maximumValue = 100
        }catch{}
        
    }
    
    // Track the amount of sound been played
    func trackVoiceMessage() {
        let progressPercentage = Float(audioPlayer!.currentTime * 100 / audioPlayer!.duration)
        progressBarSlider.value = progressPercentage
    }
    
    // MARK: Img Attachment
    func transitionImgAttachment(){
        dispatch_async(dispatch_get_main_queue()){()-> Void in
            
//            let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//            let documentDirectory = documentPath[0]
//            let destinationPath = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(self.attachmentContentObject[self.attachmentIndexShown].filePath!)
//            self.secretImg.image = UIImage(contentsOfFile: destinationPath.absoluteString)
            
            // TODO: MUST DELETE JUST FOR TRYING : image get  from assest
            self.secretImg.image = UIImage(named: self.attachmentContentObject[self.attachmentIndexShown].filePath!)!
            
            self.secretImg.contentMode = .ScaleAspectFit
            // Create Transition
            let slideTransition = CATransition()
            
            slideTransition.type = kCATransitionPush
            slideTransition.subtype = kCATransitionFromRight
            slideTransition.duration = 1
            slideTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            slideTransition.fillMode = kCAFillModeRemoved
            
            self.secretImg.layer.addAnimation(slideTransition, forKey: "SliderFromRightToLeft")
            
            self.attachmentIndexShown += 1
            if self.attachmentIndexShown == self.msg?.attachements?.count{
                self.attachmentIndexShown = 0
            }
        }
    }
    
    //TODO: MUST DELETE
    func loadInitialDataFortry(){
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let context = appDelegate.managedObjectContext
            
                
                if let message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: context) as? Message {
                    message.content = "WHaevery isnmdfmnlksjk ns df jsnd fkj sfsjdnfkjnfoijer wernkljsnf9 oisnfinso s9aduf9o d"
                    
                    var imgS = [Attachment]()
                    let attachment = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: context) as? Attachment
                        attachment!.filePath = "Concentrate and ask again.m4a"
                        attachment!.message = message
                        imgS.append(attachment!)
                    
//                    let attachment2 = NSEntityDescription.insertNewObjectForEntityForName("Attachment", inManagedObjectContext: context) as? Attachment
//                        attachment2!.filePath = "pic.png"
//                        attachment2!.message = message
//                         imgS.append(attachment2!)
                    
                    
                    print(imgS.count)
                    message.attachements = NSSet(array: imgS)
                    // Try to save
                    do {
                        try context.save()
                    }
                    catch {
                        
                    }
            }
            
            let getConversationRequest = NSFetchRequest(entityName: "Message")
            do{
                if let getConversationList = try context.executeFetchRequest(getConversationRequest).first as? Message{
                    self.msg = getConversationList
                }
            }catch{}
            
        }
//        func playVoiceMessage(){
//            
//            do{
//                updaterForProgressSlider = CADisplayLink(target: self, selector: #selector(SecretMessageViewController.trackVoiceMessage))
//                updaterForProgressSlider.frameInterval = 1
//                updaterForProgressSlider.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
//                
//                let path = NSBundle.mainBundle().pathForResource("Concentrate and ask again", ofType: "m4a")
//                if let path2 = path {
//                    let url = NSURL.fileURLWithPath(path2)
//                    try audioPlayer = AVAudioPlayer(contentsOfURL: url)
//                    audioPlayer?.delegate = self
//                    audioPlayer?.play()
//                    
//                    progressBarSlider.minimumValue = 0
//                    progressBarSlider.maximumValue = 100 // Percentage
//                }
//            }catch{}
//            
//        }
    }
    

    


}
