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
        NSLog("Begin context done.")
        layer.render(in: UIGraphicsGetCurrentContext()!)
        NSLog("Layer render done.")
        let image = UIGraphicsGetImageFromCurrentImageContext()
        NSLog("Get image done.")
        UIGraphicsEndImageContext()
        NSLog("End context done.")
        return image!
    }
}

