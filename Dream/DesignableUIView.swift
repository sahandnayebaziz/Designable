//
//  DreamDesignable.swift
//  Dream
//
//  Created by Sahand on 9/8/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

enum DesignableUIViewType: String, Codable {
    case rectangle
}

struct DesignableDescription: Codable {
    var type: DesignableUIViewType
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var style: DesignableDescriptionStyleAttributes
    
    func toUIViewDesignable() -> UIViewDesignable {
        switch type {
        case .rectangle:
            let view = DesignableUIViewRectangle()
            if let fillColor = style.color {
                view.backgroundColor = UIColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
            }
            return view
        }
    }
}

protocol UIViewDesignable: class {
    var designableDescription: DesignableDescription { get }
    var preGesturePositionDescription: DesignablePreGestureDescription? { get set }
}

struct DesignableDescriptionStyleAttributes: Codable {
    var color: DesignableDescriptionStyleAttributes.FillColor?
    
    struct FillColor: Codable {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
    }
}
