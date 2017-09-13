//
//  UIViewDesignableRectangleUIView.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

class UIViewDesignableRectangleUIView: UIView, UIViewDesignable {
    
    let type: UIViewDesignableType = .rectangle
    var preGesturePositionDescription: DesignablePreGestureDescription? = nil
    var link: DesignableDescriptionLink? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var designableDescription: DesignableDescription {
        let frameToSave: CGRect
        
        if let pre = preGesturePositionDescription {
            frameToSave = pre.frame
        } else {
            frameToSave = frame
        }
        
        let fillColor = CIColor(color: backgroundColor!)
        let fillColorAttribute = DesignableDescriptionAttributesStyle.FillColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
        let style = DesignableDescriptionAttributesStyle(color: fillColorAttribute)
        
        return DesignableDescription(type: .rectangle, x: frameToSave.minX, y: frameToSave.minY, width: frameToSave.width, height: frameToSave.height, style: style, image: nil, link: link)
    }
}
