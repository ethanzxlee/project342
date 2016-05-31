//
//  TintedAlertViewController.swift
//  Project342
//
//  Created by Zhe Xian Lee on 30/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

/// A custom alert view controller that allows the tint color of
/// the actions to be changed
/// However, the original tint (blue) color still visible when the view
/// controller is disappearing from the view
class TintedAlertViewController: UIAlertController {

    /** The custom tint color */
    var customTintColor = UIColor.themeColor()
    
    /** Temporarily holds the original tint color */
    private var windowOriginalTintColor: UIColor?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Swap the tint color to the custom color
        windowOriginalTintColor = view.window?.tintColor
        view.window?.tintColor = customTintColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset the original window tint color
        view.window?.tintColor = windowOriginalTintColor
    }
    
}
