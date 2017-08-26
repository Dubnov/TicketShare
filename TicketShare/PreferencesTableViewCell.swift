//
//  PreferencesTableViewCell.swift
//  TicketShare
//
//  Created by dor dubnov on 8/17/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class PreferencesTableViewCell: UITableViewCell {
    var data:PreferencesOption!
    
    @IBOutlet weak var btnCheck: UISwitch!
    @IBOutlet weak var lblSuggestion: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
