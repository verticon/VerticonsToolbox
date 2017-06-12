//
//  Data.swift
//  VerticonsToolbox
//
//  Created by Robert Vaessen on 5/17/17.
//  Copyright © 2017 Verticon. All rights reserved.
//

import Foundation

// TODO: Rethink the forced unwrapping of the String initializers
public extension Data {
    
    public init(with: String, using: String.Encoding = .utf8) {
        self.init()
        self.append(with.data(using: using)!)
        self.append(0)
    }
    
    public init(with: [String], using: String.Encoding = .utf8) {
        self.init()
        with.forEach { self.append(Data(with: $0, using: using)) }
    }
    
    public func toString(encoding: String.Encoding = .utf8) -> String {
        return String(data: self, encoding: encoding)!
    }
    
    public func toStringArray(encoding: String.Encoding = .utf8) -> [String] {
        
        return withUnsafeBytes { (ptr: UnsafePointer<Int8>) in
            
            var strings = [String]()
            
            var start = ptr
            for offset in 0 ..< self.count {
                
                let current = ptr + offset
                
                if current != start && current.pointee == 0 {
                    // if we cannot decode the string, append a unicode replacement character
                    // feel free to handle this another way.
                    strings.append(String(cString: start, encoding: encoding) ?? "\u{FFFD}")
                    start = current + 1
                }
            }
            
            return strings
        }
    }
    
    public func toHexString(seperator: String) -> String {
        return self.map { String(format: "%02hhX", $0) }.joined(separator: seperator)
    }
}

// http://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data
public extension Data {
    
    public init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    public func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    public init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }
    
    public func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}

//*****************************************************************************************************************************

public protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

public extension DataConvertible {
    
    public init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    public var data: Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension Int8 : DataConvertible { }
extension UInt8 : DataConvertible { }
extension Int16 : DataConvertible { }
extension UInt16 : DataConvertible { }
extension Int32 : DataConvertible { }
extension UInt32 : DataConvertible { }
extension Int64 : DataConvertible { }
extension UInt64 : DataConvertible { }
extension Float : DataConvertible { }
extension Double : DataConvertible { }
