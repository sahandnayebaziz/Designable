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

extension UIViewDesignable {
    func inspectableDuplicate(inView designView: DesignView, recordedIn undoManager: UndoManager) {
        let description = designableDescription
        
        guard let newView = description.toUIViewDesignable() as? UIView else {
            fatalError("Couldn't convert description to UIView base")
        }
        
        designView.elementsView.addSubview(newView)
        newView.center = designView.elementsView.center
    }
    
    func inspectableReplace(from fromDesignableDescription: DesignableDescription, to newDesignableDescription: DesignableDescription, recordedIn undoManager: UndoManager) {
        let newView = newDesignableDescription.toUIViewDesignable()
        
        undoManager.registerUndo(withTarget: newView as! UIView) { v in
            (v as? UIViewDesignable)?.inspectableReplace(from: newDesignableDescription, to: fromDesignableDescription, recordedIn: undoManager)
        }
        
        guard let containingView = (self as? UIView)?.superview else {
            fatalError("Can't replace a view not on DesignView yet")
        }
        
        (self as! UIView).removeFromSuperview()
        containingView.addSubview(newView as! UIView)
    }
}

extension DesignView {
    
    func undoableInspectableChangeFillColor(of designable: UIViewDesignable, from fromColor: UIColor, to toColor: UIColor) {
        guard designable.inspectableAttributeTypes.contains(.fillColor) else {
            fatalError("Can't change color in this element.")
        }
        
        guard let designableAsUIView = designable as? UIView else {
            fatalError("Can't set fill color on one that doesn't turn into a UIView")
        }
        
        designUndoManager.registerUndo(withTarget: self) { designView in
            designView.undoableInspectableChangeFillColor(of: designable, from: toColor, to: fromColor)
        }
        
        designableAsUIView.backgroundColor = toColor
        delegate?.didChange(self)
    }
}
