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
import MapKit

class SecretMessageViewController: UIViewController {
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var secretMessageTitle: UITextView!
    
    @IBOutlet weak var secretImg: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    
    var msg: Message?
    
    var timer = NSTimer()
    
    let line = CAShapeLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: MUST DELETE
//        loadInitialDataFortry()
        
        // Load the message content into the text view. if it iis empty, hide the view
        // If gt message MEAN it is not voice message

        let type = msg?.type
        print(type)
        if type == MessageType.NormalMessage.rawValue {
            self.secretMessageTitle.text = "Secret Message"
            
            let content = UILabel()
            content.text = msg?.content
            content.font = UIFont(name: "HelveticaNeue", size: 16)
            content.numberOfLines = 0
            content.lineBreakMode = .ByWordWrapping
            content.sizeToFit()
            
            content.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-20, height: self.view.frame.height/3)
            
            secretImg.addSubview(content)
        }else if type == MessageType.Image.rawValue{
            dispatch_async(dispatch_get_main_queue()){()-> Void in
                
                let attachments = self.msg!.attachements!.allObjects as! [Attachment]
                let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentDirectory = documentPath[0]
                
                let img = UIImage(named: "\(documentDirectory)/\(attachments[0].filePath!)")
                print("img: \(documentDirectory)/\(attachments[0].filePath!)")
                let imgView = UIImageView(image: img!)
                let newFrame = CGRect(x: 0, y: 0, width: self.secretImg.frame.size.width, height: self.secretImg.frame.size.height-10)
                imgView.contentMode = .ScaleAspectFit
                imgView.frame = newFrame
                if self.secretImg.subviews.count > 0{
                    self.secretImg.willRemoveSubview(self.secretImg.subviews[0])
                }
                self.secretImg.addSubview(imgView)
                
                self.secretMessageTitle.text = "Secret Image"
            }
        }else{
         
            let coordinates = msg!.content?.componentsSeparatedByString(",")
            let lat = (coordinates![0] as NSString).doubleValue
            let lon = (coordinates![1] as NSString).doubleValue
            
            let newFrame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
            let map = MKMapView(frame: newFrame)
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let regionRadius = 200.0
            map.setRegion(MKCoordinateRegionMakeWithDistance(location, regionRadius*2 , regionRadius*2) , animated: true)
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = location
            map.addAnnotation(dropPin)
            
            self.secretImg.addSubview(map)
            self.secretMessageTitle.text = "Secret Map"
        }
        
        self.secretMessageTitle.font = UIFont(descriptor: UIFontDescriptor(name: "AmericanTypewriter-Bold", size: 20)  , size: 30)
        self.secretMessageTitle.textColor = UIColor.whiteColor()
        self.secretMessageTitle.textAlignment = .Center
        
        
        
        
        
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
    
    //
    //    func textViewBorder(){
    //
    //        let path = UIBezierPath()
    //
    //        path.moveToPoint(CGPoint(x: self.secretMessage.frame.minX, y: self.secretMessage.frame.maxY+15))
    //        path.addLineToPoint(CGPoint(x: self.secretMessage.frame.maxX, y: self.secretMessage.frame.maxY+15))
    //
    //        line.path = path.CGPath
    //        line.strokeColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.5).CGColor
    //        self.view.layer.addSublayer(line)
    //    }

    

    


}
