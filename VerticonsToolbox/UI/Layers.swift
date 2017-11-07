//
//  Layers.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 10/31/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import UIKit

public class DebugLayer : CATextLayer {
 
    public static let minLineNumber = 1
    public static let maxLineNumber = 10

    public static func add(to: UIView) -> DebugLayer {
        let layer = DebugLayer()
        layer.frame = to.bounds
        //layer.alignmentMode = kCAAlignmentCenter
        layer.foregroundColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor

        to.layer.addSublayer(layer)

        return layer
    }
    
    private var lines = [Int : String]()
    
    public func update(line: Int, with: String) {
        guard line >= DebugLayer.minLineNumber && line <= DebugLayer.maxLineNumber else { return } // Fail silently
        
        lines[line] = with
        
        var orderedLines = Array<String>(repeating: "", count: DebugLayer.maxLineNumber)
        lines.forEach { orderedLines[$0.key] = $0.value }

        self.string = orderedLines.reduce(""){ $0 + $1 + "\n" }
    }
}
