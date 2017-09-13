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
//        let rendererFormat = UIGraphicsImageRendererFormat.default()
//        rendererFormat.opaque = isOpaque
//        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: rendererFormat)
//
//        setNeedsLayout()
//        layoutIfNeeded()
//
//        let snapshotImage = renderer.image { _ in
//            drawHierarchy(in: bounds, afterScreenUpdates: true)
//        }
//        return snapshotImage
        
        let totallyUnrelatedView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        totallyUnrelatedView.backgroundColor = .red
        
//        totallyUnrelatedView.setNeedsLayout()
//        totallyUnrelatedView.setNeedsDisplay()
        
        UIGraphicsBeginImageContextWithOptions(totallyUnrelatedView.bounds.size, true, totallyUnrelatedView.contentScaleFactor)
//        totallyUnrelatedView.layer.render(in: UIGraphicsGetCurrentContext()!)
        totallyUnrelatedView.drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
//        UIGraphicsBeginImageContextWithOptions(bounds.size, true, contentScaleFactor)
//        layer.render(in: UIGraphicsGetCurrentContext()!)
////        drawHierarchy(in: bounds, afterScreenUpdates: true)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image!
    }
}

//UIGraphicsBeginImageContextWithOptions(self.bounds.size,
//                                       YES, self.contentScaleFactor);
//[self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
//UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//UIGraphicsEndImageContext();
//return newImage;

