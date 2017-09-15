//
//  Thumbnails.swift
//  Designable
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

extension Designable {
    enum thumbnailRenderQuality {
        case fast, highQuality
    }
}

extension UIView {
    func renderToImage(_ quality: Designable.thumbnailRenderQuality) -> UIImage {
        switch quality {
        case .fast:
            UIGraphicsBeginImageContextWithOptions(bounds.size, true, contentScaleFactor)
            NSLog("Begin context done.")
            layer.render(in: UIGraphicsGetCurrentContext()!)
            NSLog("Layer render done.")
            let image = UIGraphicsGetImageFromCurrentImageContext()
            NSLog("Get image done.")
            UIGraphicsEndImageContext()
            NSLog("End context done.")
            return image!
        case .highQuality:
            let rendererFormat = UIGraphicsImageRendererFormat.default()
            rendererFormat.opaque = isOpaque
            let renderer = UIGraphicsImageRenderer(size: bounds.size, format: rendererFormat)
            let snapshotImage = renderer.image { _ in
                drawHierarchy(in: bounds, afterScreenUpdates: true)
            }
            return snapshotImage
        }
    }
}

