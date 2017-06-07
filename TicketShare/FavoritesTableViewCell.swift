//
//  FavoritesTableViewCell.swift
//  TicketShare
//
//  Created by Chen g on 05/05/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var dateIcon: UIImageView!
    @IBOutlet weak var locIcon: UIImageView!
    @IBOutlet weak var priceIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
        self.locIcon.image = UIImage(named: "loc")
        self.dateIcon.image = UIImage(named: "calendar")
        self.priceIcon.image = UIImage(named: "price")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
