//
//  SingleChoiceCell.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation
import UIKit

class ChoiceCell: UITableViewCell {
    
    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var choiceBtn: UIButton!
    @IBOutlet weak var choiceIcon: UIImageView!
    @IBOutlet weak var choiceLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var choiceIconWidthConstraint: NSLayoutConstraint!
    
    var optionId: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        choiceLabel.font =  choiceLabel.font.withSize(18);
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
