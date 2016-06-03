//
//  UILocalNotificationExtensions.swift
//  Project342
//
//  Created by Zhe Xian Lee on 04/06/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

extension UILocalNotification {
    
    static func scheduleNewContactNotification() {
        let alertBody = NSLocalizedString("You've got a new contact", comment: "New contact notification alert body")
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.alertBody = alertBody
        notification.soundName = UILocalNotificationDefaultSoundName
        
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    static func scheduleNewMessageNotification() {
        let alertBody = NSLocalizedString("You've got a new message", comment: "New message notification alert body")
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.alertBody = alertBody
        notification.soundName = UILocalNotificationDefaultSoundName
        
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}
