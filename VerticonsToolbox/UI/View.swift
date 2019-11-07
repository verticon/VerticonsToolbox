//
//  View.swift
//  Toolbox
//
//  Created by Robert Vaessen on 9/26/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

public extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    var viewController : UIViewController? {
        func findViewController(forResponder responder: UIResponder) -> UIViewController? {
            if let nextResponder = responder.next {
                switch nextResponder {
                case is UIViewController:
                    return nextResponder as? UIViewController
                case is UIView:
                    return findViewController(forResponder: nextResponder)
                default:
                    break
                }
            }
            return nil
        }
        
        return findViewController(forResponder: self)
    }

    // Draw a circle with a line through it
    func drawFailureIndication(lineWidth: CGFloat) {

        let context = UIGraphicsGetCurrentContext()!;
        context.saveGState()

        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(lineWidth)
        
        // First the circle
        
        let minDimension = bounds.maxX < bounds.maxY ? bounds.maxX : bounds.maxY
        let side = minDimension - lineWidth
        
        context.addEllipse(in: CGRect(x: bounds.midX - (side / 2), y: bounds.midY - (side / 2), width: side, height: side))
        context.strokePath()
        
        // Then the line
        
        let radius = Double(side / 2)
        
        let startAngle = 135 * Double.pi / 180
        let startX = radius * cos(startAngle)
        let startY = -radius * sin(startAngle) // Positive Y is down instead of up, hence the negative sign to correct
        
        let finishAngle = 315 * Double.pi / 180
        let finishX = radius * cos(finishAngle)
        let finishY = -radius * sin(finishAngle)
        
        context.translateBy(x: bounds.midX, y: bounds.midY)     // Place the origin in the middle
        context.move(to: CGPoint(x: startX, y: startY))         // Move onto the circle at the start angle
        context.addLine(to: CGPoint(x: finishX, y: finishY))    // Draw a line across the circle
        context.strokePath()
        context.translateBy(x: -bounds.midX, y: -bounds.midY)   // Put the origin back to where it was

        context.restoreGState()
    }
}

@IBDesignable open class GradientView: UIView {
    @IBInspectable @objc dynamic public var firstColor = UIColor.white
    @IBInspectable @objc dynamic public var secondColor = UIColor.black
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override open func layoutSubviews() {
        (layer as? CAGradientLayer)?.colors = [firstColor.cgColor, secondColor.cgColor]
        super.layoutSubviews()
    }
}

/*
public extension UIView {
    /*
     let myCustomView = CustomView.fromNib() // NIB named "CustomView"
     let myCustomView: CustomView? = CustomView.fromNib()  // NIB named "CustomView" might not exist
     let myCustomView = CustomView.fromNib("some other NIB name")
     
     I encountered some difficulty with the connection of the NIB to the custom class' outlets.
     I found that I needed to configure the NIB in a certain way:
     1) For the Fileowner - In the Identity Inspector, leave the Custom Class blank
     2) For the outermost View - In the Identity Inspector, set the Custom Class to the desired class
     3) For the outermost View - In the Connection Inspector, make the connections to the subviews in the Document Outline.
     */

    /* Throws an exception if the view specifies connections because no owner is provided to which to wire the outlets
        Strangely, it seems to be okay for the nib to specify actions.


     2017-03-18 17:04:24.122 Nibs[51960:29042640] *** Terminating app due to uncaught exception 'NSUnknownKeyException', reason: '[<NSObject 0x61000000b7c0> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key clickMe.'
     *** First throw call stack:
     (
     0   CoreFoundation                      0x000000010be96d4b __exceptionPreprocess + 171
     1   libobjc.A.dylib                     0x00000001098d921e objc_exception_throw + 48
     2   CoreFoundation                      0x000000010be96c99 -[NSException raise] + 9
     3   Foundation                          0x00000001093e79df -[NSObject(NSKeyValueCoding) setValue:forKey:] + 291
     4   UIKit                               0x000000010a1b779e -[UIRuntimeOutletConnection connect] + 109
     5   CoreFoundation                      0x000000010be3b9e0 -[NSArray makeObjectsPerformSelector:] + 256
     6   UIKit                               0x000000010a1b6122 -[UINib instantiateWithOwner:options:] + 1867
     7   UIKit                               0x000000010a1b83bb -[NSBundle(UINSBundleAdditions) loadNibNamed:owner:options:] + 223
     8   VerticonsToolbox                    0x00000001093482f6 _TZFE16VerticonsToolboxCSo6UIView7fromNibuRxS0_rfTGSqSS_4typeMx_GSqx_ + 1158
     9   VerticonsToolbox                    0x0000000109347c83 _TZFE16VerticonsToolboxCSo6UIView7fromNibuRxS0_rfTGSqSS_4typeMx_x + 163
     10  VerticonsToolbox                    0x0000000109347bb1 _TZFE16VerticonsToolboxCSo6UIView7fromNibfGSqSS_DS0_ + 145
     11  VerticonsToolbox                    0x0000000109347e0c _TToZFE16VerticonsToolboxCSo6UIView7fromNibfGSqSS_DS0_ + 204
     12  Nibs                                0x0000000109299b47 _TFC4Nibs18NibsViewController11viewDidLoadfT_T_ + 711
     13  Nibs                                0x0000000109299d02 _TToFC4Nibs18NibsViewController11viewDidLoadfT_T_ + 34
     14  UIKit                               0x0000000109f4aa3d -[UIViewController loadViewIfRequired] + 1258
     15  UIKit                               0x0000000109f4ae70 -[UIViewController view] + 27
     16  UIKit                               0x0000000109e144b5 -[UIWindow addRootViewControllerViewIfPossible] + 71
     17  UIKit                               0x0000000109e14c06 -[UIWindow _setHidden:forced:] + 293
     18  UIKit                               0x0000000109e28519 -[UIWindow makeKeyAndVisible] + 42
     19  UIKit                               0x0000000109da0f8d -[UIApplication _callInitializationDelegatesForMainScene:transitionContext:] + 4818
     20  UIKit                               0x0000000109da70ed -[UIApplication _runWithMainScene:transitionContext:completion:] + 1731
     21  UIKit                               0x0000000109da426d -[UIApplication workspaceDidEndTransaction:] + 188
     22  FrontBoardServices                  0x000000010f3516cb __FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 24
     23  FrontBoardServices                  0x000000010f351544 -[FBSSerialQueue _performNext] + 189
     24  FrontBoardServices                  0x000000010f3518cd -[FBSSerialQueue _performNextFromRunLoopSource] + 45
     25  CoreFoundation                      0x000000010be3b761 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17
     26  CoreFoundation                      0x000000010be2098c __CFRunLoopDoSources0 + 556
     27  CoreFoundation                      0x000000010be1fe76 __CFRunLoopRun + 918
     28  CoreFoundation                      0x000000010be1f884 CFRunLoopRunSpecific + 420
     29  UIKit                               0x0000000109da2aea -[UIApplication _run] + 434
     30  UIKit                               0x0000000109da8c68 UIApplicationMain + 159
     31  Nibs                                0x000000010929b66f main + 111
     32  libdyld.dylib                       0x000000010dcd468d start + 1
     )
     libc++abi.dylib: terminating with uncaught exception of type NSException
     */
    public class func fromNib(_ nibNameOrNil: String? = nil) -> Self {
        return fromNib(nibNameOrNil, type: self)
    }
    
    public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromNib(nibNameOrNil, type: T.self)
        return v!
    }
    
    public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T? {

        let name = nibNameOrNil == nil ? nibName : nibNameOrNil!
        
        if let views = Bundle(for: type).loadNibNamed(name, owner: nil) {
            for view in views  {
                if let v = view as? T { return v }
            }
        }
        
        return nil
    }
    
    public class var nibName: String {
        let name = "\(self)".components(separatedBy: ".").first ?? ""
        return name
    }
    
    public class var nib: UINib? {
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return UINib(nibName: nibName, bundle: nil)
        } else {
            return nil
        }
    }
}
 */
