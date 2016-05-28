//
//  CustomLabel.swift
//  Project342
//
//  Created by Fagan Ooi on 29/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func drawTextInRect(rect: CGRect) {
        let inset = UIEdgeInsetsMake(1, 5, 1, 5)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, inset))
    }

}
