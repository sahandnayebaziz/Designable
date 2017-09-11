//
//  Projects.swift
//  Dream
//
//  Created by Sahand on 9/9/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

struct Project: Codable {
    var name: String
    var description: String
    var flows: [Flow]
}

struct Flow: Codable {
    var id: String
    var name: String
    var pages: [Page]
}

struct Page: Codable {
    var id: String
    var name: String
    var layers: [DesignableDescription]
}

struct DesignableDescription: Codable {
    var type: DesignableUIViewType
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var style: DesignableDescriptionAttributesStyle
    var link: DesignableDescriptionLink?
}



