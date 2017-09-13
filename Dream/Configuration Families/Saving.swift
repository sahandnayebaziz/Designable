//
//  Saving.swift
//  Dream
//
//  Created by Sahand on 9/10/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

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
    
    static var imageCache: [String: UIImage] = [:]
    
    static func save(_ image: UIImage, with filename: String) {
        imageCache[filename] = image
        
        let path = "images/\(filename)"
        
        guard let jpegData = UIImageJPEGRepresentation(image, 0.5) else {
            fatalError("Could not get JPEG data of image")
        }
        
        dispatch_to_background_queue {
            do {
                try Disk.save(jpegData, to: .documents, as: path)
                dispatch_to_main_queue {
                    imageCache[filename] = nil
                }
            } catch {
                print("received error saving: \(path)")
                print(error as NSError)
            }
        }
    }
    
    static func loadImage(named filename: String, completion: @escaping ((UIImage?) -> Void)) {
        if let image = imageCache[filename] {
            completion(image)
            return
        }
        
        dispatch_to_background_queue {
            do {
                let data = try Dream.Disk.retrieve("images/\(filename)", from: .documents)
                dispatch_to_main_queue {
                    completion(UIImage(data: data))
                }
            } catch {
                print(error as NSError)
            }
        }
    }
}

extension Flow {
    func toJSON() -> String {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            guard let string = String(data: data, encoding: .utf8) else {
                return ""
            }
            return string
        } catch {
            return ""
        }
    }
}
