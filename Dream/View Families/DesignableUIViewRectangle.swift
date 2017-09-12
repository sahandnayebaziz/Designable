//
//  DesignableUIViewRectangle.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

class DesignableUIViewRectangle: UIView, UIViewDesignable {
    
    var preGesturePositionDescription: DesignablePreGestureDescription? = nil
    var link: DesignableDescriptionLink? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        alpha = 0.75
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var designableDescription: DesignableDescription {
        let frameToSave: CGRect
        
        if let pre = preGesturePositionDescription {
            frameToSave = CGRect(x: pre.center.x - (pre.width / 2), y: pre.center.y - (pre.height / 2), width: pre.width, height: pre.height)
        } else {
            frameToSave = frame
        }
        
        let fillColor = CIColor(color: backgroundColor!)
        let fillColorAttribute = DesignableDescriptionAttributesStyle.FillColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
        let style = DesignableDescriptionAttributesStyle(color: fillColorAttribute)
        
        return DesignableDescription(type: .rectangle, x: frameToSave.minX, y: frameToSave.minY, width: frameToSave.width, height: frameToSave.height, style: style, link: link)
    }
}
