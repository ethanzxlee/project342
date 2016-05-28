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
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var contentViewCell: UIView!
    
    @IBOutlet weak var contentLeading: NSLayoutConstraint!
    @IBOutlet weak var contentTrailing: NSLayoutConstraint!
    @IBOutlet weak var profileLeading: NSLayoutConstraint!
    @IBOutlet weak var profileTrailing: NSLayoutConstraint!
    @IBOutlet weak var attachmentLeading: NSLayoutConstraint!
    @IBOutlet weak var attachmentTrailing: NSLayoutConstraint!
    @IBOutlet weak var attachmentBottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageContent.layer.borderColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
        messageContent.layer.borderWidth = 1
        messageContent.layer.cornerRadius = 7
        messageContent.clipsToBounds = true
        
        profileView.layer.cornerRadius = 12
        profileView.clipsToBounds = true
        
        contentViewCell.addConstraint(NSLayoutConstraint(item: contentViewCell, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 220))
        

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
