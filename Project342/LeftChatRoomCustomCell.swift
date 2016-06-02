//
//  LeftChatRoomCustomCell.swift
//  Project342
//
//  Created by Fagan Ooi on 29/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class LeftChatRoomCustomCell: UITableViewCell {
    
    @IBOutlet weak var messageContent: CustomLabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var contentViewCell: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageContent.backgroundColor = UIColor.init(red: 102/255, green: 1, blue: 1, alpha: 1.0)
        profileView.layer.cornerRadius = 12
        profileView.clipsToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
