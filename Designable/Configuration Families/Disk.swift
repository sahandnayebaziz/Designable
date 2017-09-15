//
//  Disk.swift
//  Designable
//
//  Created by Sahand on 9/9/17.
//  Copyright © 2017 Sahand. All rights reserved.
//

import Foundation
import UIKit

extension Designable {

    struct Disk {
        enum Directory: String {
            case documents = "<Application_Home>/Documents"
            case caches = "<Application_Home>/Library/Caches"
            case temporary = "<Application_Home>/tmp"
        }
        
        public enum ErrorCode: Int {
            case noFileFound = 0
            case serialization = 1
            case deserialization = 2
            case invalidFileName = 3
            case couldNotAccessUserDomainMask = 4
        }
        
        public static let errorDomain = "DiskErrorDomain"
        
        static func createError(_ errorCode: ErrorCode, description: String?, failureReason: String?, recoverySuggestion: String?) -> Error {
            let errorInfo: [String: Any] = [NSLocalizedDescriptionKey : description ?? "",
                                            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? "",
                                            NSLocalizedFailureReasonErrorKey: failureReason ?? ""]
            return NSError(domain: errorDomain, code: errorCode.rawValue, userInfo: errorInfo) as Error
        }
        
        static func createURL(for path: String?, in directory: Directory) throws -> URL {
            let filePrefix = "file://"
            var validPath: String? = nil
            if let path = path {
                do {
                    validPath = try getValidFilePath(from: path)
                } catch {
                    throw error
                }
            }
            var searchPathDirectory: FileManager.SearchPathDirectory
            switch directory {
            case .documents:
                searchPathDirectory = .documentDirectory
            case .caches:
                searchPathDirectory = .cachesDirectory
            case .temporary:
                var temporaryUrl = URL(string: NSTemporaryDirectory())!
                if let validPath = validPath {
                    temporaryUrl = temporaryUrl.appendingPathComponent(validPath, isDirectory: false)
                }
                if temporaryUrl.absoluteString.lowercased().prefix(filePrefix.characters.count) != filePrefix {
                    let fixedUrl = filePrefix + temporaryUrl.absoluteString
                    temporaryUrl = URL(string: fixedUrl)!
                }
                return temporaryUrl
            }
            if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
                if let validPath = validPath {
                    url = url.appendingPathComponent(validPath, isDirectory: false)
                }
                if url.absoluteString.lowercased().prefix(filePrefix.characters.count) != filePrefix {
                    let fixedUrl = filePrefix + url.absoluteString
                    url = URL(string: fixedUrl)!
                }
                return url
            } else {
                throw createError(
                    .couldNotAccessUserDomainMask,
                    description: "Could not create URL for \(directory.rawValue)/\(validPath ?? "")",
                    failureReason: "Could not get access to the file system's user domain mask.",
                    recoverySuggestion: "Use a different directory."
                )
            }
        }
        
        static func getExistingFileURL(for path: String?, in directory: Directory) throws -> URL {
            do {
                let url = try createURL(for: path, in: directory)
                if FileManager.default.fileExists(atPath: url.path) {
                    return url
                }
                throw createError(
                    .noFileFound,
                    description: "Could not find an existing file or folder at \(url.path).",
                    failureReason: "There is no existing file or folder at \(url.path)",
                    recoverySuggestion: "Check if a file or folder exists before trying to commit an operation on it."
                )
            } catch {
                throw error
            }
        }
        
        static func getValidFilePath(from originalString: String) throws -> String {
            var invalidCharacters = CharacterSet(charactersIn: ":")
            invalidCharacters.formUnion(.newlines)
            invalidCharacters.formUnion(.illegalCharacters)
            invalidCharacters.formUnion(.controlCharacters)
            let pathWithoutIllegalCharacters = originalString
                .components(separatedBy: invalidCharacters)
                .joined(separator: "")
            let validFileName = removeSlashesAtBeginning(of: pathWithoutIllegalCharacters)
            guard validFileName.characters.count > 0  && validFileName != "." else {
                throw createError(
                    .invalidFileName,
                    description: "\(originalString) is an invalid file name.",
                    failureReason: "Cannot write/read a file with the name \(originalString) on disk.",
                    recoverySuggestion: "Use another file name with alphanumeric characters."
                )
            }
            return validFileName
        }
        
        static func removeSlashesAtBeginning(of string: String) -> String {
            var string = string
            if string.prefix(1) == "/" {
                string.remove(at: string.startIndex)
            }
            if string.prefix(1) == "/" {
                string = removeSlashesAtBeginning(of: string)
            }
            return string
        }
        
        static func isFolder(_ url: URL) -> Bool {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    return true
                }
            }
            return false
        }
        
        static func createSubfoldersBeforeCreatingFile(at url: URL) throws {
            do {
                let subfolderUrl = url.deletingLastPathComponent()
                var subfolderExists = false
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: subfolderUrl.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        subfolderExists = true
                    }
                }
                if !subfolderExists {
                    try FileManager.default.createDirectory(at: subfolderUrl, withIntermediateDirectories: true, attributes: nil)
                }
            } catch {
                throw error
            }
        }
        
        static func exists(_ path: String, in directory: Directory) -> Bool {
            if let _ = try? getExistingFileURL(for: path, in: directory) {
                return true
            }
            return false
        }
        
        static func remove(_ path: String, in directory: Directory) throws {
            do {
                if let url = try? getExistingFileURL(for: path, in: directory) {
                    try FileManager.default.removeItem(at: url)
                }
                return
            } catch {
                throw error
            }
        }
        
        static func createFolder(to directory: Directory, as path: String) throws {
            do {
                let folderUrl = try createURL(for: path, in: directory)
                try createSubfoldersBeforeCreatingFile(at: folderUrl)
                try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: nil)
            } catch {
                throw error
            }
        }
        
        static func save(_ value: Data, to directory: Directory, as path: String) throws {
            do {
                let url = try createURL(for: path, in: directory)
                try createSubfoldersBeforeCreatingFile(at: url)
                try value.write(to: url, options: .atomic)
            } catch {
                throw error
            }
        }
        
        static func retrieve(_ path: String, from directory: Directory) throws -> Data {
            do {
                let url = try getExistingFileURL(for: path, in: directory)
                let data = try Data(contentsOf: url)
                return data
            } catch {
                throw error
            }
        }
        
        static func save<T: Encodable>(_ value: T, to directory: Directory, as path: String) throws {
            do {
                let url = try createURL(for: path, in: directory)
                let encoder = JSONEncoder()
                let data = try encoder.encode(value)
                try createSubfoldersBeforeCreatingFile(at: url)
                try data.write(to: url, options: .atomic)
            } catch {
                throw error
            }
        }
        
        static func retrieve<T: Decodable>(_ path: String, from directory: Directory, as type: T.Type) throws -> T {
            do {
                let url = try getExistingFileURL(for: path, in: directory)
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let value = try decoder.decode(type, from: data)
                return value
            } catch {
                throw error
            }
        }
        
        static func retrieveAll<T: Decodable>(_ path: String, from directory: Directory, as type: T.Type) throws -> [T] {
            do {
                let url = try getExistingFileURL(for: path, in: directory)
                let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                var objects = [T]()
                
                let decoder = JSONDecoder()
                
                for i in 0..<fileUrls.count {
                    let fileUrl = fileUrls[i]
                    let data = try Data(contentsOf: fileUrl)
                    let decoded = try decoder.decode(type, from: data)
                    objects.append(decoded)
                }
                
                return objects
            } catch {
                throw error
            }
        }
    }
}

