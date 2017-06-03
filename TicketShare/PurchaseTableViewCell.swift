//
//  PurchaseTableViewCell.swift
//  TicketShare
//
//  Created by Chen g on 29/04/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class PurchaseTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblBuyerSellerLabel: UILabel!
    @IBOutlet weak var lblBuyerSellerValue: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var lblDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
