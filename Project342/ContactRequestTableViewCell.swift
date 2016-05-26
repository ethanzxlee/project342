//
//  ContactRequestTableViewCell.swift
//  Project342
//
//  Created by Zhe Xian Lee on 26/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit


class ContactRequestTableViewCell: UITableViewCell {
 
    @IBOutlet weak var contactProfileImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    var didAcceptButtonPressedAction: (() -> (Void))?
    
    
    override func awakeFromNib() {
        acceptButton.layer.borderWidth = 1
        acceptButton.layer.borderColor = UIColor.themeColor().CGColor
        acceptButton.layer.cornerRadius = 4   
    }
    
    
    @IBAction func didAcceptButtonPressed(sender: UIButton) {
        guard
            let didAcceptButtonPressedAction = didAcceptButtonPressedAction
            else {
                return
        }
        
        didAcceptButtonPressedAction()
    }
    
    
}