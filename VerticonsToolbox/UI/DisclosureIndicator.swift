//
//  DisclosureIndicator.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 7/31/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import UIKit

public class DisclosureIndicator: UIControl {

    public static func create(color: UIColor?, highlightedColor: UIColor?) -> DisclosureIndicator{
        let indicator = DisclosureIndicator(frame: CGRect(x: 0, y: 0, width: 11, height: 15))
        if let color = color { indicator.color = color }
        if let color = highlightedColor { indicator.highlightedColor = color }
        return indicator
    }

    public var color: UIColor = .black
    public var highlightedColor: UIColor = .white
   
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!;
        
        // (x,y) is the tip of the arrow
        let x = self.bounds.maxX - 3.0;
        let y = self.bounds.midY;

        let length : CGFloat = 4.5;
        context.move(to: CGPoint(x: x - length, y: y - length))
        context.addLine(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x - length, y: y + length))
        context.setLineCap(.round)
        context.setLineJoin(.miter)
        context.setLineWidth(3)
        
        context.setStrokeColor((isHighlighted ? highlightedColor : color).cgColor)

        context.strokePath()
    }
    
    override public var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            setNeedsDisplay()
        }
    }
}
