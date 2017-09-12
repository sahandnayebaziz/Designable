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
    case fillColor, link
    
    var menuOptionTitle: String {
        switch self {
        case .fillColor:
            return "Color"
        case .link:
            return "Link to Page"
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
        }
    }
}

extension UIViewDesignable {
    
    var inspectableAttributeTypes: [UIViewDesignableInspectableAttributeType] {
        switch type {
        case .rectangle:
            return [.fillColor, .link]
        }
    }
    
}
