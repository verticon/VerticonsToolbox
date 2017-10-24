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
        return UIFont(descriptor: fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.featureSettings: [[UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType, UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]]]), size: 0)
    }
}
