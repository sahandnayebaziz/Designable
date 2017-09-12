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
    case rectangle
}

extension DesignableDescription {
    func toUIViewDesignable() -> UIViewDesignable {
        switch type {
        case .rectangle:
            let view = UIViewDesignableRectangleUIView()
            view.frame = CGRect(x: x, y: y, width: width, height: height)
            if let fillColor = style.color {
                view.backgroundColor = UIColor(red: fillColor.red, green: fillColor.green, blue: fillColor.blue, alpha: fillColor.alpha)
            }
            view.link = link
            return view
        }
    }
}

extension UIViewDesignable {
    func inspectableChangeFillColor(from fromColor: UIColor, toColor: UIColor, recordedIn undoManager: UndoManager) {
        guard inspectableAttributeTypes.contains(.fillColor) else {
            fatalError("Can't change color in this element.")
        }
        
        undoManager.registerUndo(withTarget: self) { view in
            view.inspectableChangeFillColor(from: toColor, toColor: fromColor, recordedIn: undoManager)
        }
        
        (self as! UIView).backgroundColor = toColor
    }
    
    func inspectableDuplicate(inView designView: DesignView, recordedIn undoManager: UndoManager) {
        let description = designableDescription
        
        guard let newView = description.toUIViewDesignable() as? UIView else {
            fatalError("Couldn't convert description to UIView base")
        }
        
        designView.elementsView.addSubview(newView)
        newView.center = designView.elementsView.center
    }
}
