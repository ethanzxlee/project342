//
//  TableViewCellCreateNewChat.swift
//  Project342
//
//  Created by Fagan Ooi on 20/05/2016.
//  Copyright © 2016 UOW. All rights reserved.
//

import UIKit

class TableViewCellCreateNewChat: UITableViewCell {
    
    @IBOutlet weak var circularIndicator: UIView!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        circularIndicator.layer.borderColor = UIColor.grayColor().CGColor
//        circularIndicator.layer.cornerRadius = circularIndicator.frame.width/2
//        circularIndicator.layer.borderWidth = 1.0
//        circularIndicator.layer.masksToBounds = true
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = UIColor.clearColor()
//        self.selectedBackgroundView = backgroundView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
