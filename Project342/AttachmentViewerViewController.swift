//
//  AttachmentViewerViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import MapKit

class AttachmentViewerViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imgViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgViewBottomConstraint: NSLayoutConstraint!
    
    
    @IBAction func doneButtonFunc(sender: AnyObject) {
        self.performSegueWithIdentifier("backToChatRoom", sender: self)
    }
    
    var message : Message?
    
    var img:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if message?.type == MessageType.Image.rawValue{
            let attachment = (message?.attachements!.allObjects as! [Attachment])[0]
            
            let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentDirectory = documentPath[0]
            
            img = UIImage(named: "\(documentDirectory)/\(attachment.filePath!)")
            
            imgView.image = img
            imgView.contentMode = .ScaleAspectFit
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action:#selector(AttachmentViewerViewController.longPressFunc(_:)))
            longPressGesture.minimumPressDuration = 0.4
            self.view.addGestureRecognizer(longPressGesture)
            
            scrollView.delegate = self
            scrollView.maximumZoomScale = CGFloat.infinity
        }else if message?.type == MessageType.Map.rawValue{
            let coordinates = message!.content?.componentsSeparatedByString(",")
            let lat = (coordinates![0] as NSString).doubleValue
            let lon = (coordinates![1] as NSString).doubleValue
            
            let newFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            let map = MKMapView(frame: newFrame)
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let regionRadius = 200.0
            map.setRegion(MKCoordinateRegionMakeWithDistance(location, regionRadius*2 , regionRadius*2) , animated: true)
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = location
            map.addAnnotation(dropPin)
            
            self.view.addSubview(map)
            self.imgView.removeFromSuperview()

        }else{
            let content = UILabel()
            content.text = message?.content
            content.font = UIFont(name: "HelveticaNeue", size: 16)
            content.numberOfLines = 0
            content.lineBreakMode = .ByWordWrapping
            content.sizeToFit()
            
            content.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-20, height: self.view.frame.height)
            
            self.view.addSubview(content)
            self.imgView.removeFromSuperview()
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
    
    // MARK: Scroll View
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateContraintForView(view.bounds.size)
    }
    
    func updateContraintForView(size: CGSize){
        let yOffset = max(0, (size.height - imgView.frame.height)/2)
        let xOffset = max(0, (size.width - imgView.bounds.width)/2)
        
        imgViewTopConstraint.constant = yOffset
        imgViewBottomConstraint.constant = yOffset
        
        imgViewLeadingConstraint.constant = xOffset
        imgViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    // Long Press function for Saved Image
    func longPressFunc(longPressGestureRecognizer: UILongPressGestureRecognizer){
        switch (longPressGestureRecognizer.state) {
        case .Began:
            print("Began")
            let actionSheet = UIAlertController(title: "Save Photo", message: "The option to save the photo", preferredStyle: .ActionSheet)
            let saveToAlbum = UIAlertAction(title: "Save to Cameral Roll", style: .Default) { (_) in
                UIImageWriteToSavedPhotosAlbum(self.img!, self, #selector(self.successOrNot), nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            actionSheet.addAction(saveToAlbum)
            actionSheet.addAction(cancelAction)
            self.presentViewController(actionSheet, animated: true, completion: nil)
            
        case .Cancelled:
            print("Cancelled")
        case .Changed:
            print("Changed")
        case .Ended:
            print("Ended")
            
        case .Failed:
            print("Failed")
        case .Possible:
            print("Possible")
        }
       
    }
    
    // Function needed for UIImageWriteToSavedPhotosAlbum
    func successOrNot(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafePointer<Void>){
        if error == nil {
            let successAlert = UIAlertController(title: "Saved!", message: "The image has been saved to your Cameral Roll", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            successAlert.addAction(okAction)
            self.presentViewController(successAlert, animated: true, completion: nil)
        }else{
            let failureAlert = UIAlertController(title: "Save Failed!", message: error?.localizedDescription, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            failureAlert.addAction(okAction)
            self.presentViewController(failureAlert, animated: true, completion: nil)
        }
    }
}
