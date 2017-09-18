//
//  Projects.swift
//  Designable
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
    var width: CGFloat
    var height: CGFloat
    var layers: [DesignableDescription]
    
    init(name: String, bounds: CGRect) {
        self.id = UUID().uuidString
        self.name = name
        self.width = bounds.width
        self.height = bounds.height
        self.layers = []
    }
}

struct DesignableDescription: Codable {
    var type: UIViewDesignableType
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var style: DesignableDescriptionAttributesStyle
    var image: DesignableDescriptionAttributesImage?
    var link: DesignableDescriptionLink?
}

