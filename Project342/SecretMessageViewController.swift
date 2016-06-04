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
    
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var msg: Message?
    
    var timer = NSTimer()
    
    let line = CAShapeLayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        visualEffectView.layer.cornerRadius = 8
        visualEffectView.clipsToBounds = true
        
        let type = msg?.type
        print(type)
        if type == MessageType.NormalMessage.rawValue {
            self.secretMessageTitle.text = "Message"
            
//            let content = UILabel()
            content.text = msg?.content
            content.numberOfLines = 0
            content.lineBreakMode = .ByWordWrapping
            content.sizeToFit()
            content.translatesAutoresizingMaskIntoConstraints = false
            
            
            
//            content.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-20, height: self.view.frame.height/3)
            
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
        
        self.secretMessageTitle.font = UIFont.systemFontOfSize(30)
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
    

}
