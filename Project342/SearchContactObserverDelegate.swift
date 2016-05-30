//
//  SearchContactObserverDelegate.swift
//  Project342
//
//  Created by Zhe Xian Lee on 31/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import Foundation


///
protocol SearchContactObserverDelegate {
    /**
     Will be called when the search response is updated
     
     - Parameters:
     - observer: The observer that called this method
     - searchResponse: The updated search response
     */
    func didSearchContactResponseUpdate(observer: SearchContactObserver, searchResponse: [[String: AnyObject]])
}
