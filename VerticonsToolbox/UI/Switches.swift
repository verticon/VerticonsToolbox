//
//  Switches.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 5/18/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import UIKit

class VerticallyCenteredTextLayer : CATextLayer {
    
    // REF: http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
    // CREDIT: David Hoerl - https://github.com/dhoerl
    // USAGE: To fix the vertical alignment issue that currently exists within the CATextLayer class.
    
    override func draw(in ctx: CGContext) {
        let fontSize = self.fontSize
        let height = self.bounds.size.height
        let deltaY = (height-fontSize)/2 - fontSize/10
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: deltaY)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}

@IBDesignable public class TitledSwitch : UISwitch {
    private let titleLayer = VerticallyCenteredTextLayer()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        titleLayer.frame = bounds
        titleLayer.alignmentMode = kCAAlignmentCenter
        layer.addSublayer(titleLayer)
        titleLayer.foregroundColor = isEnabled ? titleColorEnabled.cgColor : titleColorDisabled.cgColor
    }

    @IBInspectable public var title: String = "" {
        didSet {
            titleLayer.string = title
        }
    }

    @IBInspectable public var titleColorEnabled: UIColor = UIColor.darkGray
    
    @IBInspectable public var titleColorDisabled: UIColor = UIColor.lightGray
 
    @IBInspectable public var titleSize: Float = 15 {
        didSet {
            titleLayer.fontSize = CGFloat(titleSize)
        }
    }
    
    override public var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            titleLayer.foregroundColor = isEnabled ? titleColorEnabled.cgColor : titleColorDisabled.cgColor
        }
    }
}
