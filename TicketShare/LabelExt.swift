//
//  LabelExt.swift
//  TicketShare
//
//  Created by Shay H on 08/05/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

extension UILabel {
    
    var substituteFontName : String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
    }
}
