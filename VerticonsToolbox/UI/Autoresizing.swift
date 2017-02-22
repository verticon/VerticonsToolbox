//
//  Autoresizing.swift
//  Toolbox
//
//  Created by Robert Vaessen on 9/26/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

extension UIViewAutoresizing : CustomStringConvertible {
    private static let values: [UIViewAutoresizing] = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    private static let names = ["None", "Width", "Height", "Top", "Right", "Bottom", "Left"]
    public var description : String {
        get {
            var description = ""
            for (i, value) in UIViewAutoresizing.values.enumerated() {
                if contains(value) {
                    if description.characters.count > 0 { description += "|" }
                    description += UIViewAutoresizing.names[i]
                }
            }
            return description
        }
    }
}
