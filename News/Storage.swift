//
//  Storage.swift
//  News
//
//  Created by James Wilkinson on 17/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Storage {
    associatedtype StorageType
    
    subscript(_ key: String) -> StorageType? { get set }
}

extension UserDefaults: Storage {
    subscript(_ key: String) -> String? {
        get {
            return self.string(forKey: key)
        }
        set {
            guard let newValue = newValue else {
                self.set(nil, forKey: key)
                return
            }
            
            self.set(newValue, forKey: key)
        }
    }
}

protocol CustomJSONConvertible {
    init?(json: JSON)
    func toJSON() -> JSON
}

class JSONFlatFile: Storage {
    private static let userDocumentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    static let `default` = JSONFlatFile(directoryURL: URL(fileURLWithPath: userDocumentsDirectoryPath))
    
    let directoryURL: URL
    
    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }
    
    typealias StorageType = JSON
    
    subscript(_ key: String) -> JSON? {
        get {
            guard let all = try? String(contentsOf: directoryURL.appendingPathComponent("\(key).json"), encoding: .utf8) else { return nil }
            return JSON.parse(all)
        }
        set {
            guard let newValue = newValue else {
                do {
                    try FileManager.default.removeItem(at: directoryURL.appendingPathComponent("\(key).json"))
                } catch let e {
                    print("Could not delete file: \(e)")
                }
                return
            }
            
            try? newValue.rawString(.utf8, options: [])!.write(to: directoryURL.appendingPathComponent("\(key).json"), atomically: true, encoding: .utf8)
        }
    }
    
    subscript(_ key: String) -> CustomJSONConvertible? {
        get {
            return self[key]
        }
        set {
            self[key] = newValue?.toJSON()
        }
    }
}
