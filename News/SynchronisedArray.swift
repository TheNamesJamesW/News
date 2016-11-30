//
//  SynchronisedArray.swift
//  News
//
//  Created by James Wilkinson on 20/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import Foundation

// Based on http://stackoverflow.com/a/28191539

public class SynchronisedArray<T> {
    private let accessQueue = DispatchQueue(label: "com.jameswilkinson.syncArray")
    private var innerArray: [T]    
    
    /// Synchronised read/write for entire array
    var array: [T] {
        set {
            self.accessQueue.async(flags: .barrier) {
                self.innerArray = newValue
            }
        }
        get {
            var array: [T]!
            
            self.accessQueue.sync {
                array = self.innerArray
            }
            
            return array
        }
    }
    
    convenience init() {
        self.init([])
    }
    
    init(_ array: [T]) {
        self.innerArray = array
    }
    
    public func append(_ newElement: T) {
        self.accessQueue.async(flags: .barrier) {
            self.innerArray.append(newElement)
        }
    }
    
    public func append<C: Collection>(contentsOf other: C) where C.Iterator.Element == T {
        self.accessQueue.async(flags: .barrier) {
            self.innerArray.append(contentsOf: other)
        }
    }
    
    public subscript(index: Int) -> T {
        set {
            self.accessQueue.async(flags: .barrier) {
                self.innerArray[index] = newValue
            }
        }
        get {
            var element: T!
            
            self.accessQueue.sync {
                element = self.innerArray[index]
            }
            
            return element
        }
    }
}

