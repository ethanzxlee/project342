//
//  AddContactTableViewCell.swift
//  Project342
//
//  Created by Zhe Xian Lee on 27/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class AddContactTableViewCell: UITableViewCell {

    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var requestSentLabel: UILabel!
    
    var addButtonAction: (() -> Void)?
    
    
    override func awakeFromNib() {
        addButton.layer.borderColor = UIColor.themeColor().CGColor
        addButton.layer.borderWidth = 1
        addButton.layer.cornerRadius = 4
        
        contactImageView.layer.cornerRadius = contactImageView.layer.frame.height / 2
        contactImageView.layer.masksToBounds = true
    }
    
    
    @IBAction func didTouchAddButton(sender: UIButton) {
        guard
            let addButtonAction = addButtonAction
            else {
                return
        }
        
        addButtonAction()
    }
    
    
}
