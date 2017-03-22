//
//  UIFont.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 3/22/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

extension UIFont
{
    public var monospacedDigitFont: UIFont
    {
        return UIFont(descriptor: fontDescriptor.addingAttributes([UIFontDescriptorFeatureSettingsAttribute: [[UIFontFeatureTypeIdentifierKey: kNumberSpacingType, UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector]]]), size: 0)
    }
}
