//
//  ChatRoomCustomCell.swift
//  Project342
//
//  Created by Fagan Ooi on 28/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class ChatRoomCustomCell: UITableViewCell{
    
    // For message receiver from others
    @IBOutlet weak var messageContent: CustomLabel!
    @IBOutlet weak var profileView: UIImageView!
    
    @IBOutlet weak var contentLeading: NSLayoutConstraint!
    @IBOutlet weak var contentTrailing: NSLayoutConstraint!
    @IBOutlet weak var profileLeading: NSLayoutConstraint!
    @IBOutlet weak var profileTrailing: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageContent.layer.borderColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        messageContent.layer.borderWidth = 1
        messageContent.layer.cornerRadius = 7
        messageContent.clipsToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
