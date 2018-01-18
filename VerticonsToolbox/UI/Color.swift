//
//  Color.swift
//  Toolbox
//
//  Created by Robert Vaessen on 9/26/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

public extension UIColor {
    func toImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(cgColor);
        context?.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!;
    }
    
    func lighten() -> UIColor { return adjustBrightness(by: 1.3)  }
    
    func darken() -> UIColor {  return adjustBrightness(by: 0.75)  }
    
    private func adjustBrightness(by: CGFloat) -> UIColor {
        var hue, saturation, brightness, alpha : CGFloat
        hue = 0.0; saturation = 0.0; brightness = 0.0; alpha = 0.0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: min(by * brightness, 1.0), alpha: alpha)
    }
}
