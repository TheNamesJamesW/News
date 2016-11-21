//
//  DictionaryExt.swift
//  News
//
//  Created by James Wilkinson on 21/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation

extension Dictionary {
    func mapPair<OutKey, OutValue>( transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey : OutValue] {
        let mapped = try map(transform)
        return Dictionary<OutKey, OutValue>(mapped)
    }
    
    func flatMapPair<OutKey, OutValue>(_ transform: (Element) throws -> (OutKey?, OutValue?)) rethrows -> [OutKey : OutValue] {
        let filtered: [(OutKey, OutValue)] = try map(transform).flatMap {
            guard let key = $0.0, let value = $0.1 else { return nil }
            return (key, value)
        }
        return Dictionary<OutKey, OutValue>(filtered)
    }
    
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}
