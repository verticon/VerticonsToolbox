//
//  BackgroundColorButton.swift
//
//  Created by Robert Vaessen on 12/16/15.
//  Copyright © 2015 Robert Vaessen. All rights reserved.
//

import UIKit

@IBDesignable
open class ColoredButton: UIButton {
    @IBInspectable open var color: UIColor? {
        didSet {
            setBackgroundColor(color, forState: UIControlState())
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

@IBDesignable
open class ToggleButton: ColoredButton {
    
    open var listener: ((Bool) -> Void)?
    
    @IBInspectable open var selectedColor: UIColor? {
        didSet {
            setBackgroundColor(selectedColor, forState: .selected)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private func initialize() {
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    open func toggle() {
        isSelected = !isSelected
        if let listener = listener { listener(isSelected) }
    }
}

public extension UIButton {
    public func setBackgroundColor(_ color: UIColor?, forState state: UIControlState) {
        if let color = color {
            setBackgroundImage(color.toImage(), for: state)
        }
        else {
            setBackgroundImage(nil, for: state)
        }
    }
}
