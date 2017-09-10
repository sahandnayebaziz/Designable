//
//  Saving.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation


extension Dream {
    
    static func prepareDisk() {
        do {
            if !Dream.Disk.exists("projects/", in: .documents) {
                try Dream.Disk.createFolder(to: .documents, as: "projects/")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    static func loadProjects() -> [Project] {
        do {
            prepareDisk()
            return try Disk.retrieveAll("projects/", from: .documents, as: Project.self)
        } catch let error as NSError {
            print(error)
            return []
        }
    }
    
    static func save(_ project: Project) {
        do {
            try Disk.save(project, to: .documents, as: "projects/\(project.name).json")
            NSLog("Project saved.\n\(project)")
        } catch let error as NSError {
            print(error)
        }
    }
    
    static func delete(_ project: Project) throws {
        let filename = "projects/\(project.name).json"
        
        do {
            guard Disk.exists(filename, in: .documents) else {
                return
            }
            
            try Disk.remove(filename, in: .documents)
        } catch {
            throw error
        }
    }
    
}
