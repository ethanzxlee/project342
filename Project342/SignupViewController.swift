//
//  SignupViewController.swift
//  Cipher
//
//  Created by Jason Lee on 26/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var facebookButtonTopConstraint: NSLayoutConstraint!
    
    var inputemail: String = ""
    var inputpwd: String = ""
    var inputfname: String = ""
    var inputlname: String = ""
    var invalidemail: Bool = false
    var invalidpwd: Bool = false
    
    var ref: FIRDatabaseReference!
    var documentDirectory: NSURL?
    var screenHeight: CGFloat?
    var tag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get reference for firebase's database
        ref = FIRDatabase.database().reference()
        
        // Get document directory and assign to the variable
        guard let documentDirectoryTmp = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else{
            return
        }
        documentDirectory = documentDirectoryTmp
        
        // Determine iPhone model based on screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        screenHeight = screenSize.height
        
        email.delegate = self
        password.delegate = self
        firstname.delegate = self
        lastname.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Add facebook icon to button
        let facebookIcon = UIImageView()
        let facebook = UIImage(named: "facebook.png")
        facebookIcon.image = facebook
        facebookIcon.frame = CGRect(x: 8, y: 3, width: 40, height: 40)
        facebookBtn.addSubview(facebookIcon)
        
        // Add email icon in email UITextField
        let emailIcon = UIImageView()
        let emailimage = UIImage(named: "email.png")
        emailIcon.image = emailimage
        emailIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        email.addSubview(emailIcon)
        let leftView1 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        email.leftView = leftView1
        email.leftViewMode = UITextFieldViewMode.Always
        
        // Add password icon in email UITextField
        let passwordIcon = UIImageView()
        let passwordimage = UIImage(named: "password.png")
        passwordIcon.image = passwordimage
        passwordIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        password.addSubview(passwordIcon)
        let leftView2 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        password.leftView = leftView2
        password.leftViewMode = UITextFieldViewMode.Always
        
        // Add firstname icon in email UITextField
        let fnIcon = UIImageView()
        let fnimage = UIImage(named: "firstname.png")
        fnIcon.image = fnimage
        fnIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        firstname.addSubview(fnIcon)
        let leftView3 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        firstname.leftView = leftView3
        firstname.leftViewMode = UITextFieldViewMode.Always
        
        // Add lastname icon in email UITextField
        let lnIcon = UIImageView()
        let lnimage = UIImage(named: "lastname.png")
        lnIcon.image = lnimage
        lnIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        lastname.addSubview(lnIcon)
        let leftView4 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        lastname.leftView = leftView4
        lastname.leftViewMode = UITextFieldViewMode.Always
        
        // Disable signup button by default
        // Button will be enable once user complete the form
        signupBtn.enabled = false
        signupBtn.alpha = 0.6

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(screenHeight)
        if screenHeight == 480 || screenHeight == 568{
            registerForKeyboardNotifications()
        }
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
        
        if screenHeight == 480 || screenHeight == 568{
            deregisterForKeyboardNotification()
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldClear(textField: UITextField) -> Bool {
        signupBtn.enabled = false
        signupBtn.alpha = 0.6
        
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }else{
            //Hide the keyboard
            textField.resignFirstResponder()
            
            print(inputemail)
            print(inputpwd)
            print(inputfname)
            print(inputlname)
            
            // Enable the login button once all textfield is filled
            // All must be filled for the button to be enabled
            if !(self.inputemail.isEmpty) && !(self.inputpwd.isEmpty) && !(self.inputfname.isEmpty) && !(self.inputlname.isEmpty) {
                if !invalidemail {
                    signupBtn.enabled = true
                    signupBtn.alpha = 1.0
                }
            }
            
        }
        
        return false
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        tag = textField.tag
        signupBtn.enabled = false
        signupBtn.alpha = 0.6
        
        // Input invalid email, reset the textfield back to normal
        if textField.tag == 1 && invalidemail{
            self.email.font = UIFont(name: (self.email.font?.fontName)!, size:16)
            self.email.textColor = UIColor.blackColor()
            self.email.text = ""
        }
        
        // Input invalid password, reset the textfield back to normal
        if textField.tag == 2 && invalidpwd{
            self.password.secureTextEntry = true
            self.password.font = UIFont(name: (self.password.font?.fontName)!, size:16)
            self.password.textColor = UIColor.blackColor()
            self.password.text = ""
        }
    }
    func textFieldDidEndEditing(textField: UITextField){
        switch (textField.tag) {
        case 1:
            tag = textField.tag
            inputemail = textField.text!
            
            // Run checking and setting animation in background thread
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                
                // Check for valid email, if is invalid run follows
                if !(self.isValidEmail(self.inputemail)){
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.07
                    animation.repeatCount = 4
                    animation.autoreverses = true
                    animation.fromValue = NSValue(CGPoint: CGPointMake(self.email.center.x - 10, self.email.center.y))
                    animation.toValue = NSValue(CGPoint: CGPointMake(self.email.center.x + 10, self.email.center.y))
                
                    // Back to main thread to update the UI
                    dispatch_async(dispatch_get_main_queue(), {
                        self.email.layer.addAnimation(animation, forKey: "position")
                        self.email.layer.borderWidth = 1.5
                        self.email.layer.borderColor = UIColor.redColor().CGColor
                        self.email.textColor = UIColor.redColor()
                        self.email.layer.cornerRadius = 4
                        self.email.font = UIFont(name: (self.email.font?.fontName)!, size:13)
                        self.email.text = "Invalid email"
                        self.invalidemail = true
                    })
                }else{
                    // Valid email
                    // Back to main thread to update the UI
                    dispatch_async(dispatch_get_main_queue(), {
                        self.email.layer.borderWidth = 1.5
                        self.email.layer.borderColor = UIColor(red:0.30, green:0.77, blue:0.09, alpha:1.0).CGColor
                        self.email.layer.cornerRadius = 4
                        self.invalidemail = false
                    })
                }

            }
            break
        case 2:
            tag = textField.tag
            inputpwd = textField.text!
        
            // Run checking and setting animation in background thread
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                
                // Cheak if password length is 6 or more character
                // Firebase password minimum requirement is 6
                if self.inputpwd.characters.count < 6{
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.07
                    animation.repeatCount = 4
                    animation.autoreverses = true
                    animation.fromValue = NSValue(CGPoint: CGPointMake(self.password.center.x - 10, self.password.center.y))
                    animation.toValue = NSValue(CGPoint: CGPointMake(self.password.center.x + 10, self.password.center.y))
                    
                    // Back to main thread to update the UI
                    dispatch_async(dispatch_get_main_queue(), {
                        self.password.layer.addAnimation(animation, forKey: "position")
                        self.password.layer.borderWidth = 1.5
                        self.password.layer.borderColor = UIColor.redColor().CGColor
                        self.password.textColor = UIColor.redColor()
                        self.password.layer.cornerRadius = 4
                        self.password.secureTextEntry = false
                        self.password.font = UIFont(name: (self.password.font?.fontName)!, size:13)
                        self.password.text = "Password must be 6 characters long or more."
                        self.invalidpwd = true
                    })
                }else{
                    // Back to main thread to update the UI
                    dispatch_async(dispatch_get_main_queue(), {
                        self.password.layer.borderWidth = 1.5
                        self.password.layer.borderColor = UIColor(red:0.30, green:0.77, blue:0.09, alpha:1.0).CGColor
                        self.password.layer.cornerRadius = 4
                        self.invalidpwd = false
                    })
                }
                
            }
            
            break
        case 3:
            tag = textField.tag
            inputfname = textField.text!
            break
        case 4:
            tag = textField.tag
            inputlname = textField.text!
            break
        default: break
        }
        
    }
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        
        // Bring the view above keyboard
        if screenHeight == 480 {
            if tag == 1 || tag == 2 || tag == 3{
                facebookButtonTopConstraint.constant = -100
            }
            if tag == 4{
                facebookButtonTopConstraint.constant = -140
            }
        }else{
            facebookButtonTopConstraint.constant = -100
        }
       
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        // Bring the view back to original when keyboard is hide
        facebookButtonTopConstraint.constant = 20
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardShown(notification: NSNotification) {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        
        print("keyboardFrame: \(keyboardFrame)")
    }
    
    // MARK: Keyboard Functions
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignupViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignupViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignupViewController.keyboardShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func deregisterForKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: Actions
    
    @IBAction func signupFacebook(sender: AnyObject) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self, handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                print("Logged in)")
                
                // Show activity indicator to show loading
                self.progressBarDisplayer("Logging in", true)
                
                // Get an access token for signed in user
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                // Use the access token to exchange for Firebase credential
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error)
                    } else {
                        // Signed in to firebase
                        print("Signed in firebase")
                        
                        // Check if user exist in our database
                        let userRef = self.ref.child("users").child((user?.uid)!)
                        userRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                            if snapshot.value is NSNull{
                                print("New user")
                                
                                // Create a root reference, using default Firebase App
                                let storage = FIRStorage.storage()
                                
                                // Create a storage reference from our storage service
                                let storageRef = storage.referenceForURL("gs://fiery-fire-3992.appspot.com")
                                
                                // Query first_name, last_name and large profile picture using fbsdk
                                FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
                                    
                                    let strFirstName: String = (result.objectForKey("first_name") as? String)!
                                    let strLastName: String = (result.objectForKey("last_name") as? String)!
                                    let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
                                    
                                    // Get image as the NSData
                                    let data = NSData(contentsOfURL: NSURL(string: strPictureURL)!)
                                    
                                    // Run a new thread and save profile pic locally
                                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                                        self.saveProfilePicLocal((user?.uid)!, data: data!)
                                    }
                                    
                                    // Create a reference to file we're going to upload using user's id
                                    let profilePicRef = storageRef.child("ProfilePic/\((user?.uid)! as String)")
                                    
                                    // Upload the picture
                                    let uploadTask = profilePicRef.putData(data!, metadata: nil)
                                    
                                    // Done uploading picture to firebase
                                    uploadTask.observeStatus(.Success) { snapshot in
                                        print("Done")
                                    }
                                    
                                    // Get provider id, facebook's user id and email from FIRUser
                                    for profile in user!.providerData {
                                        let providerID = profile.providerID
                                        let uid = profile.uid;  // Provider-specific UID
                                        let email = profile.email
                                        
                                        // Save data to firebase
                                        self.ref.child("users").child(user!.uid).setValue(["facebookid": uid, "provider": providerID, "email": email!, "firstName": strFirstName, "lastName": strLastName])
                                    }
                                }
                            }else{
                                print("Existing user in our database")
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                MessageObserver.observer.observeMessageEvents()
                                ConversationObserver.observer.observeConversationEvents()
                                ConversationObserver.observer.observeConversationMemberEvents()
                                ContactObserver.observer.observeContactsEvents()
                                
                                // Move to tab view controller
                                let nextView = (self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController"))! as! UITabBarController
                                self.presentViewController(nextView, animated: true, completion: nil)
                            })
                            
                        })
                        
                    }
                })
            }
        });
    }
    
    @IBAction func signupNewUser(sender: AnyObject) {
        // Show activity indicator to show loading
        self.progressBarDisplayer("Signing up", true)
        
        // Sign up user with given email
        FIRAuth.auth()!.createUserWithEmail(inputemail, password: inputpwd, completion: { authData, error  in
            if error == nil {
                
                // Log user in
                FIRAuth.auth()?.signInWithEmail(self.inputemail, password: self.inputpwd) { authData, error in
                    
                    // Created date
                    let currentDate = NSDate()
                    let createdAt = NSDateFormatter.ISO8601DateFormatter().stringFromDate(currentDate)
                    
                    // Save user information to Firebase data
                    self.ref.child("users").child(authData!.uid).setValue(["provider": "Firebase", "email": self.inputemail, "firstName": self.inputfname, "lastName": self.inputlname, "createdAt": createdAt])
                    
                    MessageObserver.observer.observeMessageEvents()
                    ConversationObserver.observer.observeConversationEvents()
                    ConversationObserver.observer.observeConversationMemberEvents()
                    ContactObserver.observer.observeContactsEvents()
                    
                    // Jump to the next view
                    let nextView = (self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController"))! as! UITabBarController
                    self.presentViewController(nextView, animated: true, completion: nil)
                }
            } else {
                // Hide progress bar
                self.progressBarHider()
                
                print(error?.code)
                // Handle error here
                var message = "Unable to signup. Some error occured and try again."

                // Email already in use
                if error?.code == 17007{
                    message = "Unable to signup. Email is already taken. Use another email for your Cipher account."
                }
                // Invalid email
                else if error?.code == 17008{
                    message = "Unable to signup. Email is invalid. Use another email for your Cipher account."
                }
                // Weak password
                else if error?.code == 17026{
                    message = "Unable to signup. Password must be 6 characters long or more."
                }
                // No network error
                else if error?.code == 17020{
                    message = "Could not find available network. Make sure your network connection is working and try again."
                }
                
                let alertController = UIAlertController(title: "Signup failed", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)

            }
        })
    }
    
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    // MARK: Functions
    // Save profile pic locally
    func saveProfilePicLocal(uid: String, data: NSData){
        let imagefilename = "\(uid).jpg"
        let image = UIImage(data: data)
        
        guard let imageUrl = self.documentDirectory?.URLByAppendingPathComponent(imagefilename) else {
            return
        }
        
        guard let imageJpegRepresentation = UIImageJPEGRepresentation(image!, 0.8) else {
            return
        }
        
        // Write to disk
        if (!imageJpegRepresentation.writeToURL(imageUrl, atomically: true)) {
            return
        }
    }
    
    // Show a activity indicator view with custom string to act as a loading animation
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.color = UIColor.themeColor()
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }
    
    // Stop the loading animation
    func progressBarHider(){
        activityIndicator.stopAnimating()
        messageFrame.hidden = true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
}
