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
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Add user icon in username UITextField
        let userIcon = UIImageView()
        let user = UIImage(named: "username.png")
        userIcon.image = user
        userIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        usernameField.addSubview(userIcon)
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
//        let facebookIcon = UIImageView()
//        let facebook = UIImage(named: "facebook.png")
//        facebookIcon.image = facebook
//        facebookIcon.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        facebookButton.addSubview(facebookIcon)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
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
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error)
                    } else {
                        print("Signed in firebase")
                        
                        
                        let nextView = (self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController"))! as! UITabBarController
                        self.presentViewController(nextView, animated: true, completion: nil)
                    }
                })
            }
        });
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
