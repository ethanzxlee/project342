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
    
    var attachment : Attachment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = UIImage(named: "pic.png")!
        imgView.contentMode = .ScaleAspectFit
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
}
