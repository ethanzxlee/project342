//
//  CreateNewChatViewController.swift
//  Project342
//
//  Created by Fagan Ooi on 19/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class CreateNewChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var membersHorizontalScrollView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func cancelButtonFunc(sender: AnyObject) {
        self.performSegueWithIdentifier("backToRecentlyChat", sender: "Hello")
    }
    
    let appModel = AppModel()
    
    var contactList = [Contact]()
    override func viewDidLoad() {
        super.viewDidLoad()

        contactList = appModel.getContactList()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "contactForCreateNewChat")
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
    
    // MARK: - Table View Function
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("contactForCreateNewChat")! as UITableViewCell
        
        /**
         NSHipster.com
         Image Resizing Techniques
         http://nshipster.com/image-resizing/
         */
        // FIXME: temporay set user name
        let contact = contactList[indexPath.row]
        
        // FIXME: get the image from Directory
        let image = UIImage(named: contact.imagePath!)!
        
        let size = CGSize(width: 50, height: 50)
        let hasAlpha = false
        let scale:CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.imageView?.image = scaledImage
        
        /**
         Adi Nugroho
         Circular UIImageView in UITableView Cell
         https://medium.com/@adinugroho/circular-uiimageview-in-uitableview-cell-e1a7e1b6fe63#.2g5l01siu
         Used for: Solve the problem of round image delay
         */
        cell.imageView?.layer.cornerRadius = scaledImage.size.width/2
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.contentMode = .ScaleAspectFit
        cell.textLabel?.text = "\(contact.firstName!) \(contact.lastName!)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: Segue
    @IBAction func comeFromRecentChat(sender:UIStoryboardSegue){
        
    }

}
