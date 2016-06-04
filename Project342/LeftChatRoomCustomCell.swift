//
//  LeftChatRoomCustomCell.swift
//  Project342
//
//  Created by Fagan Ooi on 29/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class LeftChatRoomCustomCell: UITableViewCell {
    
    @IBOutlet weak var messageContent: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var contentViewCell: UIView!
    @IBOutlet weak var messageBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageBackgroundView.layer.cornerRadius = 8
        messageBackgroundView.clipsToBounds = true

        profileView.layer.cornerRadius = 12
        profileView.clipsToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
