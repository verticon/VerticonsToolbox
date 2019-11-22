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

    func aspectFit(in: CGSize) -> CGSize {
        let widthRatio = `in`.width / size.width
        let heightRatio = `in`.height / size.height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: scale * size.width, height: scale * size.height)
    }
    
    func aspectFill(in: CGSize) -> CGSize {
        var scaledSize = size
        if scaledSize.width < scaledSize.height {
            var scale = `in`.width / scaledSize.width // Make the width fit exactly
            scaledSize = CGSize(width: scale * scaledSize.width, height: scale * scaledSize.height)
            if scaledSize.height < `in`.height { // If the height ended up too small then expand
                scale = `in`.height / scaledSize.height
                scaledSize = CGSize(width: scale * scaledSize.width, height: scale * scaledSize.height)
            }
        }
        else {
            var scale = `in`.height / scaledSize.height  // Make the height fit exactly
            scaledSize = CGSize(width: scale * scaledSize.width, height: scale * scaledSize.height)
            if scaledSize.width < `in`.width { // If the width ended up too small then expand
                scale = `in`.width / scaledSize.width
                scaledSize = CGSize(width: scale * scaledSize.width, height: scale * scaledSize.height)
            }
        }
        return scaledSize
    }

    // ********************************************************************************************************
    
    private enum BlendMode {
        case multiply // This results in colors that are at least as dark as either of the two contributing sample colors
        case screen // This results in colors that are at least as light as either of the two contributing sample colors

    }

    // The degree parameter is internally clamped to the range 0 -> 1.

    // A degree <= 0 yeilds the original image, a degree >= 1 results in black
    func darken(degree: CGFloat = 0.5) -> UIImage? {
        return blend(mode: .multiply, degree: degree)
    }

    // A degree <= 0 yeilds the original image, a degree >= 1 results in white
    func lighten(degree: CGFloat = 0.5) -> UIImage? {
        return blend(mode: .screen, degree: degree)
    }

    private func blend(mode: BlendMode, degree: CGFloat) -> UIImage? {
        let context = CIContext(options: nil)

        var degree = degree
        if degree < 0 { degree = 0 }
        else if degree > 1 { degree = 1 }
    
        let filterName: String
        switch mode {
        case .multiply:
            degree = abs(degree - 1.0) // Invert the relationship between the degree and the grayscale value (see backgroundColor)
            filterName = "CIMultiplyBlendMode"
        case .screen: // As the degree increases we get more white (see backgroundColor)
            filterName = "CIScreenBlendMode"
        }

        let blender = CIFilter(name: filterName)!
        let backgroundColor = CIColor(color: UIColor(white: degree, alpha: 1))

        guard let inputImage = CIImage(image: self) else { return nil }
        blender.setValue(inputImage, forKey: kCIInputImageKey)

        guard let backgroundImageGenerator = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        backgroundImageGenerator.setValue(backgroundColor, forKey: kCIInputColorKey)
        guard let backgroundImage = backgroundImageGenerator.outputImage?.cropped(to: CGRect(origin: CGPoint.zero, size: self.size)) else { return nil }
        blender.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)

        guard let blendedImage = blender.outputImage else { return nil }

        guard let cgImage = context.createCGImage(blendedImage, from: blendedImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

public extension UIImageView {
    
    func setColor(_ newColor: UIColor) {
        if let image = self.image {
            self.image = image.withRenderingMode(.alwaysTemplate)
            tintColor = newColor
        }
    }
}
