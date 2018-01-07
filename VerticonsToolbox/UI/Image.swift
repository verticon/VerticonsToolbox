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

    private class FailureView : UIView {
        override func draw(_ rect: CGRect) {
            var lineWidth = bounds.width / 20
            if lineWidth < 1 { lineWidth = 1 }
            self.drawFailureIndication(lineWidth: lineWidth)
        }
    }

    // Return an image of a circle with a line through it; optionally including the provided text
    static func createFailureIndication(ofSize: CGSize, withText: String?) -> UIImage {
        let failureView = FailureView(frame: CGRect(x: 0, y: 0, width: ofSize.width, height: ofSize.height))

        var label: UILabel? = nil
        if let text = withText {
            let l = UILabel(frame: CGRect(x: 0, y: 0, width: ofSize.width, height: ofSize.height))
            l.backgroundColor = UIColor.clear
            l.textAlignment = .center
            l.textColor = UIColor.red
            l.font = UIFont.systemFont(ofSize: 4)
            l.numberOfLines = 0
            l.text = text

            label = l
        }
        
        UIGraphicsBeginImageContextWithOptions(failureView.bounds.size, false, 0);
        failureView.layer.render(in: UIGraphicsGetCurrentContext()!)
        label?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let failureImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return failureImage
    }
}

public extension UIImageView {

    public func aspectFitImageSize() -> CGSize {
        if let image = self.image {
            let imageSize = image.size
            let widthRatio = bounds.size.width / imageSize.width
            let heightRatio = bounds.size.height / imageSize.height
            let scale = min(widthRatio, heightRatio)
            let scaledImageWidth = scale * imageSize.width
            let scaledImageHeight = scale * imageSize.height
            
            return CGSize(width: scaledImageWidth, height: scaledImageHeight)
        }
        return CGSize.zero
    }
    
    public func aspectFillImageSize() -> CGSize {
        if let image = self.image {
            var imageSize = image.size
            if imageSize.width < imageSize.height {
                var scale = bounds.size.width / imageSize.width // Make the width fit exactly
                imageSize = CGSize(width: scale * imageSize.width, height: scale * imageSize.height)
                if imageSize.height < bounds.size.height { // If the height ended up too small then expand
                    scale = bounds.size.height / imageSize.height
                    imageSize = CGSize(width: scale * imageSize.width, height: scale * imageSize.height)
                }
            }
            else {
                var scale = bounds.size.height / imageSize.height  // Make the height fit exactly
                imageSize = CGSize(width: scale * imageSize.width, height: scale * imageSize.height)
                if imageSize.width < bounds.size.width { // If the width ended up too small then expand
                    scale = bounds.size.width / imageSize.width
                    imageSize = CGSize(width: scale * imageSize.width, height: scale * imageSize.height)
                }
            }
            return imageSize
        }
        return CGSize.zero
    }
    
    public func setColor(_ newColor: UIColor) {
        if let image = self.image {
            self.image = image.withRenderingMode(.alwaysTemplate)
            tintColor = newColor
        }
    }
}
