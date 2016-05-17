//
//  DictionaryExtensions.swift
//  Project342
//
//  Created by Zhe Xian Lee on 17/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation

extension Dictionary where Key: StringLiteralConvertible {
    
    var sortedKeys : [String] {
        return self.keys.map {"\($0)"} .sort {$0 < $1}
    }
    
}