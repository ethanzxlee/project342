//
//  LoginViewController.swift
//  Cipher
//
//  Created by Jason Lee on 26/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFacebook()
        
        // Add icon in username UITextField
        let userIcon = UIImageView()
        let user = UIImage(named: "username.png")
        userIcon.image = user
        userIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        usernameField.addSubview(userIcon)
        let leftView1 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        usernameField.leftView = leftView1
        usernameField.leftViewMode = UITextFieldViewMode.Always
        
        
        // Add icon in password UITextField
        let passwordIcon = UIImageView();
        let password = UIImage(named: "password.png")
        passwordIcon.image = password
        passwordIcon.frame = CGRect(x: 15, y: 12, width: 18, height: 18)
        passwordField.addSubview(passwordIcon)
        let leftView2 = UIView.init(frame: CGRectMake(0, 0, 35, 30))
        passwordField.leftView = leftView2
        passwordField.leftViewMode = UITextFieldViewMode.Always
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Functions
    
    func configureFacebook()
    {
        //btnFacebook.readPermissions = ["public_profile", "email", "user_friends"];
        btnFacebook.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
//        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
//             
//            let strFirstName: String = (result.objectForKey("first_name") as? String)!
//            let strLastName: String = (result.objectForKey("last_name") as? String)!
//            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
//            
//        }
        //let ref = Firebase(url: "https://fiery-fire-3992.firebaseio.com/")
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
                
//            } else if facebookResult.isCancelled {
//                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error)
                    }
                    else {
                        print(user?.uid)
                    }
                })
                
//                ref.authWithOAuthProvider("facebook", token: accessToken,
//                    withCompletionBlock: { error, authData in
//                        if error != nil {
//                            print("Login failed. \(error)")
//                        } else {
//                            print("Logged in! \(authData)")
//                            print(authData.uid)
//                            print(authData.providerData["email"])
//                        }
//                })
            }
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
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
