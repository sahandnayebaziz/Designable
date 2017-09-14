//
//  Thumbnails.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    public func renderToImage() -> UIImage {        
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, contentScaleFactor)
        layer.render(in: UIGraphicsGetCurrentContext()!)
//        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

//UIGraphicsBeginImageContextWithOptions(self.bounds.size,
//                                       YES, self.contentScaleFactor);
//[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
//UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//UIGraphicsEndImageContext();
//return newImage;

