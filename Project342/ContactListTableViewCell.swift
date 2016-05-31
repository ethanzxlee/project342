//
//  ContactListTableViewCell.swift
//  Project342
//
//  Created by Zhe Xian Lee on 17/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class ContactListTableViewCell: UITableViewCell {

    @IBOutlet weak var contactProfileImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contactProfileImageView.layer.cornerRadius = contactProfileImageView.frame.height / 2
        contactProfileImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
