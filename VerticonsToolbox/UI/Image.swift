//
//  Image.swift
//  Toolbox
//
//  Created by Robert Vaessen on 9/26/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

@IBDesignable open class RoundImageView : UIImageView {
    
    // This is the initializer that Interface Builder needs.
    // Without it the IB agent that creates an instance of the class will crash.
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public override init(image: UIImage?) {
        super.init(image: image?.roundImage())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.image = self.image?.roundImage()
    }

    open override var image: UIImage? {
        get {
            return super.image
        }
        set {
            super.image = newValue?.roundImage()
        }
    }
}

func * (lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width * rhs, height: lhs.height * rhs) }

public extension UIImage {

    func roundImage() -> UIImage {

        let newImage = self.copy() as! UIImage
        let cornerRadius = self.size.height/2
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
        let bounds = CGRect(origin: CGPoint.zero, size: self.size)
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        newImage.draw(in: bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage!

    }

    func resize(to newSize: CGSize, fit: Bool = true /* else fill */, backgroundColor: UIColor = .black) -> UIImage {
        
        assert(newSize.width > 1.0 && newSize.height > 1.0, "Must scale to at least 1x1 point destination")
        guard size != newSize else { return self }
        
        // Calculate scale factor for fit or fill
        let scaleFactor = (fit ? min : max)(newSize.width / size.width, newSize.height / size.height)
        
        // Establish drawing destination, which may start outside the drawing context bounds
        let scaledSize = size * scaleFactor
        let drawingOrigin = CGPoint(x: (newSize.width - scaledSize.width) / 2.0, y: (newSize.height - scaledSize.height) / 2.0)
        let drawingRect = CGRect(origin: drawingOrigin, size: scaledSize)
        
        // Perform drawing and return image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0); defer { UIGraphicsEndImageContext() }
        backgroundColor.setFill(); UIRectFill(CGRect(origin: .zero, size: newSize))
        self.draw(in: drawingRect)
        return UIGraphicsGetImageFromCurrentImageContext()!
        
    }
}
