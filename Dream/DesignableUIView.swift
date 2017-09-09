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
    
    func toUIViewDesignable() -> UIViewDesignable {
        switch type {
        case .rectangle:
            return DesignableUIViewRectangle()
        }
    }
}

protocol UIViewDesignable: class {
    var designableDescription: DesignableDescription { get }
    var preGesturePositionDescription: DesignablePreGestureDescription? { get set }
}

