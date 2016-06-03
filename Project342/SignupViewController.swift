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

class SignupViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    
    var inputemail: String?
    var inputpwd: String?
    var inputfname: String?
    var inputlname: String?
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        
        email.delegate = self
        password.delegate = self
        firstname.delegate = self
        lastname.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
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
    }
    
    // MARK: Actions
    
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
            case 3:
                inputfname = textField.text
                break
            case 4:
                inputlname = textField.text
                break
            default: break
        }

    }
    
    @IBAction func signupNewUser(sender: AnyObject) {
        FIRAuth.auth()!.createUserWithEmail(inputemail!, password: inputpwd!, completion: { authData, error  in
            if error == nil {
                // Log user in
                FIRAuth.auth()?.signInWithEmail(self.inputemail!, password: self.inputpwd!) { authData, error in
                    // Created date
                    let currentDate = NSDate()
                    let createdAt = NSDateFormatter.ISO8601DateFormatter().stringFromDate(currentDate)
                    
                    // Save user information to Firebase data
                    self.ref.child("users").child(authData!.uid).setValue(["provider": "Firebase", "email": self.inputemail!, "firstName": self.inputfname!, "lastName": self.inputlname!, "createdAt": createdAt])
                    
                    MessageObserver.observer.observeMessageEvents()
                    ConversationObserver.observer.observeConversationEvents()
                    ConversationObserver.observer.observeConversationMemberEvents()
                    ContactObserver.observer.observeContactsEvents()
                    
                    let nextView = (self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController"))! as! UITabBarController
                    self.presentViewController(nextView, animated: true, completion: nil)
                }
            } else {
                // Handle login error here
                print(error.debugDescription)
            }
        })
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
}
