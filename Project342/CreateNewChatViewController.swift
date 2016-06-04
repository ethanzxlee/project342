//
//  CreateNewChatViewController.swift
//  Project342
//
//  Created by Fagan Ooi on 19/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class CreateNewChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var membersList: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    @IBAction func cancelButtonFunc(sender: AnyObject) {
        self.performSegueWithIdentifier("backToRecentlyChat", sender: self)
    }
    
    @IBAction func createButtonFunc(sender: AnyObject) {
        if membersConversation.count > 0{
            self.performSegueWithIdentifier("backToRecentlyChat", sender: createButton)
        }else{
            self.getAlertMessage()
        }
        
    }
    
    let appModel = AppModel()
    
    var membersConversation = [Contact]()
    
    var contactList = [Contact]()           // Keep a list of contacts
    var filteredContactList = [Contact]()   // Keep the filtered result
    var searchActive: Bool = false          // Identiy the search bar is active or not
    
    var line = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactList = appModel.getContactList()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "createNewChatCell")
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.setEditing(true, animated: true)
        
        adjustTextView()
        
        searchBar.delegate = self
        
        textViewBorder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let button = sender as? UIBarButtonItem where button == createButton{
            if segue.identifier == "backToRecentlyChat"{
                if let destination = segue.destinationViewController as? RecentChatViewController{
                    destination.contactsForNewConversation = self.membersConversation
                }
            }
        }
    }
    
    
    // MARK: - Table View Function
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive{
            return filteredContactList.count
        }
        return contactList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("createNewChatCell", forIndexPath: indexPath)
        /**
         NSHipster.com
         Image Resizing Techniques
         http://nshipster.com/image-resizing/
         */
        var contact : Contact?
        if searchActive{
            contact = filteredContactList[indexPath.row]
        }else{
            contact = contactList[indexPath.row]
        }
                
        print(contact?.firstName)
        let documentPath = Directories.profilePicDirectory
        let url = documentPath?.URLByAppendingPathComponent(contact!.userId!)
        let image = UIImage(contentsOfFile: url!.path!)
        
        let size = CGSize(width: 50, height: 50)
        let hasAlpha = false
        let scale:CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
        
        image?.drawInRect(CGRect(origin: CGPointZero, size: size))
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
        cell.contentMode = .ScaleAspectFit
        guard let firstName = contact?.firstName,
                    lastName = contact?.lastName else{
            return UITableViewCell()
        }
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
        
        for eachMember in membersConversation{
            if eachMember == contactList[indexPath.row]{
                    tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        for index in 0..<self.membersConversation.count{
            if searchActive{
                if self.contactList[index] == self.filteredContactList[indexPath.row]{
                    self.membersConversation.removeAtIndex(index)
                }
            }else{
                if self.contactList[index] == self.contactList[indexPath.row]{
                    self.membersConversation.removeAtIndex(index)
                }
            }
            
        }
        
        
        if self.membersConversation.count == 0{
            self.createButton.title = "Create"
        }else{
            self.createButton.title = "Create (\(self.membersConversation.count))"
        }
        self.addTextToTextView()

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchActive{
            if self.searchBar.text == ""{
                membersConversation.append(contactList[indexPath.row])
            }else{
                membersConversation.append(filteredContactList[indexPath.row])
            }
        }else{
            membersConversation.append(contactList[indexPath.row])
        }
        
        createButton.title = "Create (\(membersConversation.count))"
        addTextToTextView()
    }
    
    // MARK: Segue
    @IBAction func comeFromRecentChat(sender:UIStoryboardSegue){
        
    }
    
    // MARK: TextView
    func addTextToTextView(){
        var str = ""
        for eachMember in membersConversation{
            str = "\(str), \(eachMember.firstName!) \(eachMember.lastName!)"
        }
        if membersConversation.count>0{
            //Remove ',' and ' '
            str.removeAtIndex(str.startIndex)
            str.removeAtIndex(str.startIndex)
        }
        membersList.text = str
        membersList.textColor = UIColor.blueColor()
        membersList.font = UIFont(name: "HelveticaNeue", size: 16)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                self.adjustTextView()
                self.textViewBorder()
            }
        }
        
    }
    
    func adjustTextView(){
        /**
         Eric
         iOS: Vertical aligning text in a UITextView
         http://imagineric.ericd.net/2011/03/10/ios-vertical-aligning-text-in-a-uitextview/
         */
        // Adjust the content to become top alignment and height changes according to content
        var adjustment = membersList.bounds.size.height - membersList.contentSize.height
        if adjustment < 0 {
            adjustment = 0
        }
        membersList.contentOffset = CGPoint(x: 0, y: -adjustment)
        let newSize = membersList.sizeThatFits(CGSize(width:membersList.frame.size.width, height: CGFloat.max))
        textViewHeight.constant = newSize.height
    }
    
    func textViewBorder(){
        if self.view.layer.sublayers?.count>0{
            line.removeFromSuperlayer()
        }
        
        let path = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: self.view.frame.minX+10, y: self.membersList.frame.maxY-5))
        path.addLineToPoint(CGPoint(x: self.view.frame.maxX-10, y: self.membersList.frame.maxY-5))
        
        line.path = path.CGPath
        line.strokeColor = UIColor.grayColor().CGColor
        self.view.layer.addSublayer(line)

    }
    
    // MARK: Search Bar
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        if searchText == "" {
            // Search Text Empty, so it will take the origin contact list
            searchActive = false
        }else{
            filteredContactList = appModel.searchContactList(searchText)
        }
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
        let searchText = searchBar.text
        if searchText == "" {
            // Search Text Empty, so it will take the origin contact list
            searchActive = false
        }else{
            filteredContactList = appModel.searchContactList(searchText!)
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        searchActive = true
        filteredContactList = appModel.searchContactList(text)
        self.tableView.reloadData()
        return true
    }
    
    // MARK: Alert
    func getAlertMessage(){
        let alertDialog = UIAlertController(title: "Empty Selection", message: "No Friends been selected for chat", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertDialog.addAction(cancelAction)
        alertDialog.view.setNeedsLayout()
        self.presentViewController(alertDialog, animated: true, completion: nil)
    }
    

}
