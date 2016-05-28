//
//  AttachmentViewerViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 15/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

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
    
    var attachment : Attachment?
    
    var img:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let documentDirectory = documentPath[0]
//        let destinationPath = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(attachment!.filePath!)
//        img = UIImage(named: destinationPath.absoluteString)!
        
        img = UIImage(named: "pic.png")
        
        imgView.image = img
        imgView.contentMode = .ScaleAspectFit

        let longPressGesture = UILongPressGestureRecognizer(target: self, action:#selector(AttachmentViewerViewController.longPressFunc(_:)))
        longPressGesture.minimumPressDuration = 0.4
        self.view.addGestureRecognizer(longPressGesture)
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = CGFloat.infinity
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
