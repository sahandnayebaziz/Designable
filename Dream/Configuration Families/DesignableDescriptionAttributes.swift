//
//  DesignableDescriptionAttributes.swift
//  Dream
//
//  Created by Sahand on 9/11/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

struct DesignableDescriptionAttributesStyle: Codable {
    var color: DesignableDescriptionAttributesStyle.FillColor?
    
    struct FillColor: Codable {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
    }
}

enum LinkType: String, Codable {
    case push
}

struct DesignableDescriptionLink: Codable {
    var type: LinkType
    var toPageId: String?
    var toFlowId: String?
}
