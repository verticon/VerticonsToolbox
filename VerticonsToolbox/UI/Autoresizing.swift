//
//  Autoresizing.swift
//  Toolbox
//
//  Created by Robert Vaessen on 9/26/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

extension UIView.AutoresizingMask : CustomStringConvertible {
    private static let values: [UIView.AutoresizingMask] = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
    private static let names = ["None", "Width", "Height", "Top", "Right", "Bottom", "Left"]
    public var description : String {
        get {
            var description = ""
            for (i, value) in UIView.AutoresizingMask.values.enumerated() {
                if contains(value) {
                    if description.count > 0 { description += "|" }
                    description += UIView.AutoresizingMask.names[i]
                }
            }
            return description
        }
    }
}
