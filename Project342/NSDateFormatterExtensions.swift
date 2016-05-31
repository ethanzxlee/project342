//
//  NSDateFormatterExtensions.swift
//  Project342
//
//  Created by Zhe Xian Lee on 26/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    
    static func dateFromISO8601String(string: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.dateFromString(string)
    }
    
}