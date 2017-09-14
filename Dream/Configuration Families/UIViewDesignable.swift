//
//  DreamDesignable.swift
//  Dream
//
//  Created by Sahand on 9/8/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

protocol UIViewDesignable: class {
    var type: UIViewDesignableType { get }
    var designableDescription: DesignableDescription { get }
    var preGesturePositionDescription: DesignablePreGestureDescription? { get set }
    var link: DesignableDescriptionLink? { get set }
}

enum UIViewDesignableType: String, Codable {
    case rectangle, image
}

extension DesignableDescription {
    func toUIViewDesignable() -> UIViewDesignable {
        switch type {
        case .rectangle:
            let view = UIViewDesignableRectangleUIView(frame: frame)
            view.link = link
            
            if let fillColor = style.color {
                view.backgroundColor = UIColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
            }
            
            return view
        case .image:
            guard let image = image else {
                fatalError("Image designable saved without image attribute")
            }
            
            let view = UIViewDesignableImageUIView(frame: frame, filename: image.filename)
            view.link = link
            
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            
            return view
        }
    }
    
    var frame: CGRect {
        return CGRect(x: self.x, y: self.y, width: self.width, height: self.height)
    }
}
