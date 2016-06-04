//
//  LoginViewController.swift
//  Cipher
//
//  Created by Jason Lee on 26/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginbutton: UIButton!
    @IBOutlet weak var facebookButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    var ref: FIRDatabaseReference!
    var inputemail: String?
    var inputpwd: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get reference for firebase's database
        ref = FIRDatabase.database().reference()
        usernameField.delegate = self
        passwordField.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Add user icon in email UITextField
        let emailIcon = UIImageView()
        let email = UIImage(named: "email.png")
        emailIcon.image = email
        emailIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        usernameField.addSubview(emailIcon)
        let leftView1 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        usernameField.leftView = leftView1
        usernameField.leftViewMode = UITextFieldViewMode.Always
        
        // Add lock icon in password UITextField
        let passwordIcon = UIImageView()
        let password = UIImage(named: "password.png")
        passwordIcon.image = password
        passwordIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        passwordField.addSubview(passwordIcon)
        let leftView2 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        passwordField.leftView = leftView2
        passwordField.leftViewMode = UITextFieldViewMode.Always
        
        // Add facebook icon to button
        let facebookIcon = UIImageView()
        let facebook = UIImage(named: "facebook.png")
        facebookIcon.image = facebook
        facebookIcon.frame = CGRect(x: 22, y: 3, width: 40, height: 40)
        facebookButton.addSubview(facebookIcon)
        
        // Disable login button by default
        // Button will be enable once user complete the form
        loginbutton.enabled = false
        loginbutton.alpha = 0.6
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Determine iPhone model, iPhone 4s need to adjust view when keyboard is bring up
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        
        if screenHeight == 480 {
            registerForKeyboardNotifications()
        }
    }
    
    // Hide navigation bar when view is going to disppear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
        
        // Determine iPhone model, iPhone 4s need to adjust view when keyboard is bring up
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        
        if screenHeight == 480 {
            deregisterForKeyboardNotification()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldClear(textField: UITextField) -> Bool {
        loginbutton.enabled = false
        loginbutton.alpha = 0.6
        
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
            
            // Enable the login button once both textfield is filled
            // Both must be filled for the button to be enabled
            if !(self.inputemail?.isEmpty)! && !(self.inputpwd?.isEmpty)! {
                loginbutton.enabled = true
                loginbutton.alpha = 1.0
            }
        }
        
        return false
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        loginbutton.enabled = false
        loginbutton.alpha = 0.6
    }
    func textFieldDidEndEditing(textField: UITextField){
        switch (textField.tag) {
        case 1:
            inputemail = textField.text
            break
        case 2:
            inputpwd = textField.text
            break
        default: break
        }
        
    }
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        
        facebookButtonTopConstraint.constant -= 120
        //stackViewBottomConstraint.constant -= 80
        //stackViewTopConstraint.constant -= 90
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        facebookButtonTopConstraint.constant += 120
//        stackViewBottomConstraint.constant = 15
//        stackViewTopConstraint.constant = 20
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Keyboard Functions
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterForKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Logging in with facebook
    @IBAction func facebookLogin(sender: AnyObject) {
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
    
    @IBAction func loginButton(sender: AnyObject) {
        // Show activity indicator to show loading
        self.progressBarDisplayer("Logging in", true)
        
        // Sign user in with email given
        FIRAuth.auth()?.signInWithEmail(self.inputemail!, password: self.inputpwd!) { authData, error in
            if error == nil{
                let nextView = (self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController"))! as! UITabBarController
                self.presentViewController(nextView, animated: true, completion: nil)
            }else{
                print(error?.code)
                self.progressBarHider()
                
                var message = "Unable to login. Some error occured and try again."
                
                if error?.code == 17999{
                    message = "Unable to login. Have you signed up for a Cipher account?"
                }
                else if error?.code == 17009 || error?.code == 17011{
                    message = "Unable to login, either username or password is incorrect."
                }
                else if error?.code == 17020{
                    message = "Could not find available network. Make sure your network connection is working and try again."
                }
                
                let alertController = UIAlertController(title: "Login failed", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }

    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        let alertController = UIAlertController(title: "Password reset", message: "Enter your email address. We'll send you an email to reset your password.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter your email"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, alertController] (action: UIAlertAction!) in
            self.progressBarDisplayer("Working on it", true)
            
            let input = alertController.textFields![0]
            let resetemail = input.text! as String
            
            self.requestPasswordReset(resetemail)
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    // MARK: Functions
    // Reset password
    func requestPasswordReset(email: String){
        FIRAuth.auth()?.sendPasswordResetWithEmail(email) { error in
            if error != nil {
                // An error happened.
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressBarHider()
                    
                    var message = "Some error occured. Please try again."
                    
                    if error?.code == 17008 || error?.code == 17999{
                        message = "Invalid email. Please enter a valid email."
                    }
                    else if error?.code == 17020{
                        message = "Could not find available network. Make sure your network connection is working and try again."
                    }
                    
                    let alertController = UIAlertController(title: "Reset Failed", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.progressBarHider()
                    let alertController = UIAlertController(title: "Email sent", message: "Your password has been reset. Please check your email.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)

                })
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
