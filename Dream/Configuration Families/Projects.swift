//
//  Projects.swift
//  Dream
//
//  Created by Sahand on 9/9/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation

struct Page: Codable {
    var id: String
    var layers: [DesignableDescription]
}

struct Flow: Codable {
    var id: String
    var name: String
    var pages: [Page]
}

struct Project: Codable {
    var name: String
    var description: String
    var flows: [Flow]
}
