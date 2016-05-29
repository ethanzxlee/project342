//
//  DocumentDirectories.swift
//  Project342
//
//  Created by Zhe Xian Lee on 29/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation

struct Directories {
    
    static var documentDirectory: NSURL? {
        do {
            return try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        }
        catch {
            print(error)
            return nil
        }
    }
    
    static var profilePicDirectory: NSURL? {
        let profilePicDirectory = self.documentDirectory?.URLByAppendingPathComponent("ProfilePic")
        if !NSFileManager.defaultManager().fileExistsAtPath(profilePicDirectory!.path!) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(profilePicDirectory!, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print(error)
            }
        }
        return profilePicDirectory
    }

}