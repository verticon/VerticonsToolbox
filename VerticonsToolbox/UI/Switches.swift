//
//  Switches.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 5/18/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import UIKit

public class VerticallyCenteredTextLayer : CATextLayer {
    
    // REF: http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
    // CREDIT: David Hoerl - https://github.com/dhoerl
    // USAGE: To fix the vertical alignment issue that currently exists within the CATextLayer class.
    
    override public func draw(in ctx: CGContext) {
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
        titleLayer.alignmentMode = .center
        titleLayer.foregroundColor = isEnabled ? titleColorEnabled.cgColor : titleColorDisabled.cgColor
        layer.addSublayer(titleLayer)
    }

    @IBInspectable public var title: String = "" {
        didSet {
            titleLayer.string = title
            resize()
        }
    }

    @IBInspectable public var titleSize: Float = 15 {
        didSet {
            titleLayer.fontSize = CGFloat(titleSize)
            resize()
        }
    }
    
    private func resize() {
        let font = UIFont.systemFont(ofSize: CGFloat(titleSize))
        let string = NSAttributedString(string: title, attributes: [.font : font])
        let rect = string.boundingRect(with: CGSize(width: 200, height:50), context: nil)
        let bounds = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        titleLayer.bounds = bounds
    }
    
    @IBInspectable @objc dynamic public var titleColorEnabled: UIColor = UIColor.darkGray {
        didSet {
            titleLayer.foregroundColor = titleColorEnabled.cgColor
        }
    }
    
    @IBInspectable @objc dynamic public var titleColorDisabled: UIColor = UIColor.lightGray {
        didSet {
            titleLayer.foregroundColor = titleColorDisabled.cgColor
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
