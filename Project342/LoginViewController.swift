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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var ref: FIRDatabaseReference!
    var inputemail: String?
    var inputpwd: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get reference for firebase's database
        ref = FIRDatabase.database().reference()
        usernameField.delegate = self
        passwordField
            .delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.loadingView.hidden = true
        
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
    }
    
    // Hide navigation bar when view is going to disppear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
        self.activityIndicatorView.stopAnimating()
        self.loadingView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }else{
            //Hide the keyboard
            textField.resignFirstResponder()
        }
        
        return false
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
                
                // Get loading view up
                self.loadingView.hidden = false
                self.activityIndicatorView.startAnimating()
                
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
        self.activityIndicatorView.startAnimating()
        self.loadingView.hidden = false
        
        FIRAuth.auth()?.signInWithEmail(self.inputemail!, password: self.inputpwd!) { authData, error in
            if error == nil{
                let nextView = (self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController"))! as! UITabBarController
                self.presentViewController(nextView, animated: true, completion: nil)
            }else{
                self.activityIndicatorView.stopAnimating()
                self.loadingView.hidden = true
            }
            
        }

    }
    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
//    {
//        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
//             
//            let strFirstName: String = (result.objectForKey("first_name") as? String)!
//            let strLastName: String = (result.objectForKey("last_name") as? String)!
//            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
//            
//        }
        //let ref = Firebase(url: "https://fiery-fire-3992.firebaseio.com/")
    

        
//        loginManager!.logInWithReadPermissions(["email"], handler: {
//            (facebookResult, facebookError) -> Void in
//            if facebookError != nil {
//                print("Facebook login failed. Error \(facebookError)")
//                
////            } else if facebookResult.isCancelled {
////                print("Facebook login was cancelled.")
//            } else {
////                self.performSegueWithIdentifier("ShowTabBarViewController2", sender: nil)
//                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
//                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
//                
//                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
//                    if error != nil {
//                        print(error)
//                    }
//                    else {
//                        print(user?.providerData["email"])
//                        print("Hello")
//                    }
//                })
//                
////                ref.authWithOAuthProvider("facebook", token: accessToken,
////                    withCompletionBlock: { error, authData in
////                        if error != nil {
////                            print("Login failed. \(error)")
////                        } else {
////                            print("Logged in! \(authData)")
////                            print(authData.uid)
////                            print(authData.providerData["email"])
////                        }
////                })
//            }
//        })
    //}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
