//
//  StringExtension.swift
//  TicketShare
//
//  Created by dor dubnov on 3/16/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

extension String {
    // validates the string format from unsage pointer
    public init?(validatingUTF8 cString: UnsafePointer<UInt8>) {
        if let (result, _) = String.decodeCString(cString, as: UTF8.self,
                                                  repairingInvalidCodeUnits: false) {
            self = result
        }
        else {
            return nil
        }
    }
}
