//
//  BidirectionalDictionary.swift
//  Toolbox
//
//  Created by Robert Vaessen on 1/10/17.
//  Copyright © 2017 Robert Vaessen. All rights reserved.
//

/*

// Example Usage,

// Create using Dictionary Literal
let dict : BidirectionalDictionary<String, Int> = ["Hello" : 3]
dict[3]       // Prints "Hello"
dict["Hello"] // Prints 3

// Create using initializer
let dict2 : BidirectionalDictionary<String, Int>(leftRight: ["World" : 10])

// Create using backwards initializer
let dict3 : BidirectionalDictionary<Int, String>(rightLeft: [10 : "World"])

 */

import Foundation

public struct BidirectionalDictionary<S:Hashable,T:Hashable> : ExpressibleByDictionaryLiteral {
    // Literal convertible
    public typealias Key   = S
    public typealias Value = T
    
    // Real storage
    private var st : [S : T] = [:]
    private var ts : [T : S] = [:]
    
    public init(leftRight st : [S:T]) {
        var ts : [T:S] = [:]
        
        for (key,value) in st {
            ts[value] = key
        }
        
        self.st = st
        self.ts = ts
    }
    
    public init(rightLeft ts : [T:S]) {
        var st : [S:T] = [:]
        
        for (key,value) in ts {
            st[value] = key
        }
        
        self.st = st
        self.ts = ts
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        for element in elements {
            st[element.0] = element.1
            ts[element.1] = element.0
        }
    }

    public subscript(key : S) -> T? {
        get {
            return st[key]
        }
        
        set(val) {
            if let val = val {
                st[key] = val
                ts[val] = key
            }
        }
    }
    
    public subscript(key : T) -> S? {
        get {
            return ts[key]
        }
        
        set(val) {
            if let val = val {
                ts[key] = val
                st[val] = key
            }
        }
    }
}
