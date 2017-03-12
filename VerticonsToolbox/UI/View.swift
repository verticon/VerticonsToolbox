//
//  View.swift
//  Toolbox
//
//  Created by Robert Vaessen on 9/26/16.
//  Copyright © 2016 Robert Vaessen. All rights reserved.
//

import UIKit

public extension UIView {
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable public var borderColor: UIColor? {
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
    
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    public var viewController : UIViewController? {
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
}

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
    
    public class func fromNib(_ nibNameOrNil: String? = nil) -> Self {
        return fromNib(nibNameOrNil, type: self)
    }
    
    public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromNib(nibNameOrNil, type: T.self)
        return v!
    }
    
    public class func fromNib<T : UIView>(_ nibNameOrNil: String? = nil, type: T.Type) -> T? {
/*
        var view: T?

         let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = nibName
        }

         let bundle = Bundle(for: T.self)
         let nibViews = bundle.loadNibNamed(name, owner: nil, options: nil)
         for v in nibViews! {
         if let tog = v as? T {
         view = tog
         }
         }
         
         return view
*/
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
