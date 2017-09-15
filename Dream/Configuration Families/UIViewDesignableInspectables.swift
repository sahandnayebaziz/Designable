//
//  UIViewDesignableInspectables.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

enum UIViewDesignableInspectableAttributeType: String {
    case fillColor, link, image, duplicate, moveForward, moveBackward
    
    var menuOptionTitle: String {
        switch self {
        case .fillColor:
            return "Color"
        case .link:
            return "Link to Page"
        case .image:
            return "Add Image"
        case .duplicate:
            return "Duplicate"
        case .moveForward:
            return "Forward"
        case .moveBackward:
            return "Backward"
        }
    }
    
    func setIconIn(view: UIView, selection: [UIViewDesignable]) {
        guard let selected = selection.first else {
            fatalError("Can't set an icon without a selection")
        }

        switch self {
        case .fillColor:
            guard let color = (selected as? UIView)?.backgroundColor else {
                return
            }
            
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            circleView.backgroundColor = color
            view.addSubview(circleView)
            circleView.center = view.center
            circleView.layer.cornerRadius = 20
            circleView.layer.borderColor = UIColor.lightGray.cgColor
            circleView.layer.borderWidth = 1
            circleView.clipsToBounds = true
        case .link:
            break
        case .image:
            break
        case .duplicate:
            break
        case .moveForward:
            let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            iconView.image = #imageLiteral(resourceName: "forward")
            iconView.tintColor = .darkGray
            iconView.contentMode = .scaleAspectFit
            view.addSubview(iconView)
            iconView.center = view.center
        case .moveBackward:
            let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            iconView.image = #imageLiteral(resourceName: "backward")
            iconView.tintColor = .darkGray
            iconView.contentMode = .scaleAspectFit
            view.addSubview(iconView)
            iconView.center = view.center
        }
    }
}

extension UIViewDesignable {
    
    var inspectableAttributeTypes: [UIViewDesignableInspectableAttributeType] {
        switch type {
        case .rectangle:
            return [.fillColor, .link, .image, .duplicate, .moveForward, .moveBackward]
        case .image:
            return [.link, .image, .duplicate, .moveForward, .moveBackward]
        }
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
    
    func undoableDuplicate(of designable: UIViewDesignable) {
        guard let newView = designable.designableDescription.toUIViewDesignable() as? UIView else {
            fatalError("Couldn't convert description to UIView base")
        }
        
        guard let newViewAsDesignable = newView as? UIViewDesignable else {
            fatalError("Couldn't turn new view back to designable")
        }
        
        newView.center = elementsView.center
        undoableAdd(description: newViewAsDesignable.designableDescription)
    }
    
    func undoableReplace(designable: UIViewDesignable, with replacementDesignableDescription: DesignableDescription) {
        guard let designableAsUIView = designable as? UIView else {
            fatalError("Can't set fill color on one that doesn't turn into a UIView")
        }
        
        designUndoManager.beginUndoGrouping()
        undoableRemove(view: designableAsUIView)
        undoableAdd(description: replacementDesignableDescription)
        designUndoManager.endUndoGrouping()
    }
}
