//
//  Disk.swift
//  Dream
//
//  Created by Sahand on 9/9/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import Disk

extension Dream {
    
    static let PROJECTS_JSON_PATH = "projects.json"
    
    static func loadProjects() -> [Project] {
        do {
            if Disk.exists(PROJECTS_JSON_PATH, in: .documents) {
                return try Disk.retrieve(PROJECTS_JSON_PATH, from: Disk.Directory.documents, as: [Project].self)
            }
        } catch let error as NSError {
            print(error)
            return []
        }
        
        return []
    }
    
    static func save(projects: [Project]) {
        do {
            try Disk.save(projects, to: .documents, as: "projects.json")
        } catch {
            print(error)
        }
    }
    
    static func save(newProject project: Project) {
        var projects = loadProjects()
        projects.append(project)
        save(projects: projects)
    }
    
}
