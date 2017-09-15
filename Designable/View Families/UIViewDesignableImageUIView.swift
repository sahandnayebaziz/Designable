//
//  UIViewDesignableImageUIView.swift
//  Designable
//
//  Created by Sahand on 9/12/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import UIKit

class UIViewDesignableImageUIView: UIImageView, UIViewDesignable {
    
    let type: UIViewDesignableType = .image
    var preGesturePositionDescription: DesignablePreGestureDescription? = nil
    var link: DesignableDescriptionLink? = nil
    
    var filename: String
    
    init(frame: CGRect, filename: String?) {
        if let existing = filename {
            self.filename = existing
        } else {
            self.filename = "\(UUID().uuidString).jpg"
        }
        
        super.init(frame: frame)
        backgroundColor = Designable.Colors.imageViewBackgroundGray
        
        Designable.loadImage(named: self.filename) { [ weak self ] i in
            self?.image = i
        }
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
        
        let imageAttribute = DesignableDescriptionAttributesImage(filename: filename)
        
        return DesignableDescription(type: .image, x: frameToSave.minX, y: frameToSave.minY, width: frameToSave.width, height: frameToSave.height, style: DesignableDescriptionAttributesStyle(color: nil), image: imageAttribute, link: link)
    }
    
    
    

}
